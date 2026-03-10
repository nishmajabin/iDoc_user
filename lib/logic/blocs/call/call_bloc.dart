import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/app_constants.dart';
import 'package:idoc_user/data/repostories/user_call_repository.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';

/// BLoC managing the user (patient) side of a video call.
///
/// Lifecycle:
///   1. [StartListeningForCalls] → watches Firestore for `status == 'ringing'`
///   2. [IncomingCallReceived] (internal) → emits [UserCallRinging]
///   3. [CallAccepted] → updates Firestore, inits Agora, joins channel
///   4. In-call events: [RemoteUserJoined], [RemoteUserLeft], [CallMuteToggled],
///      [CallCameraSwitched], [CallTimerTicked]
///   5. [CallEndRequested] → leaves Agora, marks Firestore `ended`
class UserCallBloc extends Bloc<UserCallEvent, UserCallState> {
  final UserCallRepository _repository;
  final String appId;

  UserCallRepository get repository => _repository;

  StreamSubscription? _incomingCallsSub;
  StreamSubscription<String?>? _callStatusSub;

  Timer? _timer;
  int _elapsedSeconds = 0;

  /// Currently ringing call metadata — kept so [CallAccepted] knows what to join.
  String? _pendingCallId;
  String? _pendingChannelName;
  String? _pendingDoctorId;
  String? _pendingDoctorName;
  String? _pendingDoctorProfileImageUrl;
  String? _currentUserId;

  UserCallBloc({
    required UserCallRepository repository,
    required this.appId,
  })  : _repository = repository,
        super(const UserCallIdle()) {
    on<StartListeningForCalls>(_onStartListening);
    on<StopListeningForCalls>(_onStopListening);
    on<IncomingCallReceived>(_onIncomingCall);
    on<IncomingCallCancelled>(_onIncomingCallCancelled);
    on<CallAccepted>(_onCallAccepted);
    on<CallRejected>(_onCallRejected);
    on<RemoteUserJoined>(_onRemoteUserJoined);
    on<RemoteUserLeft>(_onRemoteUserLeft);
    on<CallEndRequested>(_onCallEndRequested);
    on<CallMuteToggled>(_onMuteToggled);
    on<CallCameraSwitched>(_onCameraSwitched);
    on<CallTimerTicked>(_onTimerTicked);
    on<CallErrorOccurred>(_onErrorOccurred);
  }

  // ── Incoming-call listener ────────────────────────────────────────────────

  Future<void> _onStartListening(
    StartListeningForCalls event,
    Emitter<UserCallState> emit,
  ) async {
    _currentUserId = event.userId;
    await _incomingCallsSub?.cancel();

    _incomingCallsSub = _repository
        .watchIncomingCalls(userId: event.userId)
        .listen((snapshot) {
      if (isClosed) return;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final callId = doc.id;
        final status = data['status'] as String?;

        // Only react to 'ringing' calls while idle or already ringing the same call.
        if (status == 'ringing') {
          final currentState = state;
          if (currentState is UserCallIdle ||
              (currentState is UserCallRinging &&
                  currentState.callId != callId)) {
            debugPrint(
                '📞 [UserCallBloc] Incoming call detected: $callId');
            add(IncomingCallReceived(
              callId: callId,
              channelName: data['channelName'] as String? ?? callId,
              doctorId: data['doctorId'] as String? ?? '',
              doctorName: data['doctorName'] as String? ?? 'Doctor',
              doctorProfileImageUrl:
                  data['doctorProfileImageUrl'] as String?,
            ));
          }
        }
      }
    });
  }

  Future<void> _onStopListening(
    StopListeningForCalls event,
    Emitter<UserCallState> emit,
  ) async {
    await _incomingCallsSub?.cancel();
    _incomingCallsSub = null;
    emit(const UserCallIdle());
  }

  // ── Incoming-call events ──────────────────────────────────────────────────

  void _onIncomingCall(
    IncomingCallReceived event,
    Emitter<UserCallState> emit,
  ) {
    _pendingCallId = event.callId;
    _pendingChannelName = event.channelName;
    _pendingDoctorId = event.doctorId;
    _pendingDoctorName = event.doctorName;
    _pendingDoctorProfileImageUrl = event.doctorProfileImageUrl;

    // Watch the call doc so we know if the doctor cancels before user answers.
    _callStatusSub?.cancel();
    _callStatusSub = _repository
        .watchCallStatus(callId: event.callId)
        .listen((status) {
      if (isClosed) return;
      debugPrint('🔄 [UserCallBloc] Call status changed: $status');
      if (status == 'ended' || status == null) {
        // Doctor cancelled or document deleted.
        if (state is UserCallRinging) {
          add(const IncomingCallCancelled());
        }
      }
    });

    emit(UserCallRinging(
      callId: event.callId,
      channelName: event.channelName,
      doctorId: event.doctorId,
      doctorName: event.doctorName,
      doctorProfileImageUrl: event.doctorProfileImageUrl,
    ));
  }

  void _onIncomingCallCancelled(
    IncomingCallCancelled event,
    Emitter<UserCallState> emit,
  ) {
    _clearPending();
    emit(const UserCallIdle());
  }

  // ── Accept / Reject ───────────────────────────────────────────────────────

  Future<void> _onCallAccepted(
    CallAccepted event,
    Emitter<UserCallState> emit,
  ) async {
    final callId = _pendingCallId;
    final channelName = _pendingChannelName;
    final doctorName = _pendingDoctorName ?? 'Doctor';

    if (callId == null || channelName == null || _currentUserId == null) {
      debugPrint('⚠️ [UserCallBloc] Accept failed — no pending call');
      emit(const UserCallIdle());
      return;
    }

    emit(UserCallConnecting(
      callId: callId,
      channelName: channelName,
      doctorName: doctorName,
    ));

    try {
      // STEP 1: Tell Firestore that the user accepted.
      await _repository.acceptCall(callId: callId);

      // STEP 2: Watch for doctor ending the call while we're in it.
      _callStatusSub?.cancel();
      _callStatusSub =
          _repository.watchCallStatus(callId: callId).listen((status) {
        if (isClosed) return;
        debugPrint('🔄 [UserCallBloc] Call status changed: $status');
        if (status == 'ended') {
          add(const CallEndRequested());
        }
      });

      // STEP 3: Join Agora channel with deterministic UID from userId.
      await _repository.initAndJoin(
        appId: appId,
        channelName: channelName,
        userId: _currentUserId!,
        onRemoteUserJoined: (uid) {
          if (!isClosed) add(RemoteUserJoined(uid));
        },
        onRemoteUserLeft: (uid) {
          if (!isClosed) add(RemoteUserLeft(uid));
        },
        onError: (msg) {
          if (!isClosed) add(CallErrorOccurred(msg));
        },
      );

      _startTimer();
      emit(UserCallWaitingForPeer(
        callId: callId,
        channelName: channelName,
        doctorName: doctorName,
      ));
    } catch (e) {
      debugPrint('❌ [UserCallBloc] Accept/join failed: $e');
      emit(UserCallError(e.toString()));
    }
  }

  Future<void> _onCallRejected(
    CallRejected event,
    Emitter<UserCallState> emit,
  ) async {
    final callId = _pendingCallId;
    if (callId != null) {
      try {
        await _repository.rejectCall(callId: callId);
      } catch (e) {
        debugPrint('⚠️ [UserCallBloc] Reject doc error (non-fatal): $e');
      }
    }
    _clearPending();
    emit(const UserCallIdle());
  }

  // ── In-call events ────────────────────────────────────────────────────────

  void _onRemoteUserJoined(
    RemoteUserJoined event,
    Emitter<UserCallState> emit,
  ) {
    final s = state;
    final callId = _callIdFromState(s);
    final channelName = _channelNameFromState(s);
    final doctorName = _doctorNameFromState(s);
    final muted = _getMutedFromState(s);

    if (callId == null || channelName == null) return;

    emit(UserCallActive(
      callId: callId,
      channelName: channelName,
      doctorName: doctorName,
      remoteUid: event.uid,
      isMuted: muted,
      elapsedSeconds: _elapsedSeconds,
    ));
  }

  void _onRemoteUserLeft(
    RemoteUserLeft event,
    Emitter<UserCallState> emit,
  ) {
    emit(UserCallPeerLeft(elapsedSeconds: _elapsedSeconds));
  }

  Future<void> _onCallEndRequested(
    CallEndRequested event,
    Emitter<UserCallState> emit,
  ) async {
    _stopTimer();
    await _callStatusSub?.cancel();
    _callStatusSub = null;

    // Mark Firestore doc as ended.
    final callId = _pendingCallId ?? _callIdFromState(state);
    if (callId != null) {
      try {
        await _repository.endCallDocument(callId: callId);
      } catch (e) {
        debugPrint('⚠️ [UserCallBloc] endCallDocument error: $e');
      }
    }

    await _repository.leaveAndDispose();
    _clearPending();
    emit(const UserCallEnded());

    // After a short delay, return to idle so the listener can pick up new calls.
    await Future.delayed(const Duration(seconds: 1));
    if (!isClosed) emit(const UserCallIdle());
  }

  Future<void> _onMuteToggled(
    CallMuteToggled event,
    Emitter<UserCallState> emit,
  ) async {
    final newMuted = !_getMutedFromState(state);
    await _repository.muteLocalAudio(mute: newMuted);
    final current = state;
    if (current is UserCallActive) {
      emit(current.copyWith(isMuted: newMuted));
    } else if (current is UserCallWaitingForPeer) {
      emit(current.copyWith(isMuted: newMuted));
    }
  }

  Future<void> _onCameraSwitched(
    CallCameraSwitched event,
    Emitter<UserCallState> emit,
  ) async {
    await _repository.switchCamera();
  }

  void _onTimerTicked(
    CallTimerTicked event,
    Emitter<UserCallState> emit,
  ) {
    _elapsedSeconds = event.seconds;
    final current = state;
    if (current is UserCallActive) {
      emit(current.copyWith(elapsedSeconds: event.seconds));
    } else if (current is UserCallWaitingForPeer) {
      emit(current.copyWith(elapsedSeconds: event.seconds));
    }
  }

  void _onErrorOccurred(
    CallErrorOccurred event,
    Emitter<UserCallState> emit,
  ) {
    _stopTimer();
    emit(UserCallError(event.message));
  }

  // ── Timer helpers ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isClosed) add(CallTimerTicked(t.tick));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  void _clearPending() {
    _callStatusSub?.cancel();
    _callStatusSub = null;
    _pendingCallId = null;
    _pendingChannelName = null;
    _pendingDoctorId = null;
    _pendingDoctorName = null;
    _pendingDoctorProfileImageUrl = null;
  }

  bool _getMutedFromState(UserCallState s) {
    if (s is UserCallActive) return s.isMuted;
    if (s is UserCallWaitingForPeer) return s.isMuted;
    return false;
  }

  String? _callIdFromState(UserCallState s) {
    if (s is UserCallActive) return s.callId;
    if (s is UserCallWaitingForPeer) return s.callId;
    if (s is UserCallConnecting) return s.callId;
    if (s is UserCallRinging) return s.callId;
    return _pendingCallId;
  }

  String? _channelNameFromState(UserCallState s) {
    if (s is UserCallActive) return s.channelName;
    if (s is UserCallWaitingForPeer) return s.channelName;
    if (s is UserCallConnecting) return s.channelName;
    if (s is UserCallRinging) return s.channelName;
    return _pendingChannelName;
  }

  String _doctorNameFromState(UserCallState s) {
    if (s is UserCallActive) return s.doctorName;
    if (s is UserCallWaitingForPeer) return s.doctorName;
    if (s is UserCallConnecting) return s.doctorName;
    if (s is UserCallRinging) return s.doctorName;
    return _pendingDoctorName ?? 'Doctor';
  }

  @override
  Future<void> close() async {
    _stopTimer();
    await _incomingCallsSub?.cancel();
    await _callStatusSub?.cancel();
    await _repository.leaveAndDispose();
    return super.close();
  }
}
