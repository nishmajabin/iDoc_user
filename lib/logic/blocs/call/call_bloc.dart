import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/user_call_repository.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';

class UserCallBloc extends Bloc<UserCallEvent, UserCallState> {
  final UserCallRepository _repository;
  final String appId;

  UserCallRepository get repository => _repository;

  StreamSubscription? _incomingCallsSub;
  StreamSubscription<String?>? _callStatusSub;
  Timer? _timer;
  int _elapsedSeconds = 0;

  String? _pendingCallId,
      _pendingChannelName,
      _pendingDoctorId,
      _pendingDoctorName,
      _pendingDoctorProfileImageUrl,
      _currentUserId;

  UserCallBloc({required UserCallRepository repository, required this.appId})
    : _repository = repository,
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

  // ── State Extractors ──────────────────────────────────────────────────────

  bool _getMuted(UserCallState s) =>
      s is UserCallActive
          ? s.isMuted
          : s is UserCallWaitingForPeer
          ? s.isMuted
          : false;

  String? _getCallId(UserCallState s) => switch (s) {
    UserCallActive() => s.callId,
    UserCallWaitingForPeer() => s.callId,
    UserCallConnecting() => s.callId,
    UserCallRinging() => s.callId,
    _ => _pendingCallId,
  };

  String? _getChannelName(UserCallState s) => switch (s) {
    UserCallActive() => s.channelName,
    UserCallWaitingForPeer() => s.channelName,
    UserCallConnecting() => s.channelName,
    UserCallRinging() => s.channelName,
    _ => _pendingChannelName,
  };

  String _getDoctorName(UserCallState s) => switch (s) {
    UserCallActive() => s.doctorName,
    UserCallWaitingForPeer() => s.doctorName,
    UserCallConnecting() => s.doctorName,
    UserCallRinging() => s.doctorName,
    _ => _pendingDoctorName ?? 'Doctor',
  };

  // ── Timer ─────────────────────────────────────────────────────────────────

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

  // ── Cleanup ───────────────────────────────────────────────────────────────

  void _clearPending() {
    _callStatusSub?.cancel();
    _callStatusSub = null;
    _pendingCallId =
        _pendingChannelName =
            _pendingDoctorId =
                _pendingDoctorName = _pendingDoctorProfileImageUrl = null;
  }

  void _watchCallStatus(String callId, {required bool whileRinging}) {
    _callStatusSub?.cancel();
    _callStatusSub = _repository.watchCallStatus(callId: callId).listen((
      status,
    ) {
      if (isClosed) return;
      if (whileRinging &&
          (status == 'ended' || status == null) &&
          state is UserCallRinging) {
        add(const IncomingCallCancelled());
      } else if (!whileRinging && status == 'ended') {
        add(const CallEndRequested());
      }
    });
  }

  // ── Event Handlers ────────────────────────────────────────────────────────

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
            if (data['status'] != 'ringing') continue;
            final s = state;
            if (s is UserCallIdle ||
                (s is UserCallRinging && s.callId != doc.id)) {
              add(
                IncomingCallReceived(
                  callId: doc.id,
                  channelName: data['channelName'] as String? ?? doc.id,
                  doctorId: data['doctorId'] as String? ?? '',
                  doctorName: data['doctorName'] as String? ?? 'Doctor',
                  doctorProfileImageUrl:
                      data['doctorProfileImageUrl'] as String?,
                ),
              );
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

  void _onIncomingCall(
    IncomingCallReceived event,
    Emitter<UserCallState> emit,
  ) {
    _pendingCallId = event.callId;
    _pendingChannelName = event.channelName;
    _pendingDoctorId = event.doctorId;
    _pendingDoctorName = event.doctorName;
    _pendingDoctorProfileImageUrl = event.doctorProfileImageUrl;
    _watchCallStatus(event.callId, whileRinging: true);
    emit(
      UserCallRinging(
        callId: event.callId,
        channelName: event.channelName,
        doctorId: event.doctorId,
        doctorName: event.doctorName,
        doctorProfileImageUrl: event.doctorProfileImageUrl,
      ),
    );
  }

  void _onIncomingCallCancelled(
    IncomingCallCancelled event,
    Emitter<UserCallState> emit,
  ) {
    _clearPending();
    emit(const UserCallIdle());
  }

  Future<void> _onCallAccepted(
    CallAccepted event,
    Emitter<UserCallState> emit,
  ) async {
    final callId = _pendingCallId;
    final channelName = _pendingChannelName;
    final doctorName = _pendingDoctorName ?? 'Doctor';
    if (callId == null || channelName == null || _currentUserId == null) {
      emit(const UserCallIdle());
      return;
    }

    emit(
      UserCallConnecting(
        callId: callId,
        channelName: channelName,
        doctorName: doctorName,
      ),
    );

    try {
      await _repository.acceptCall(callId: callId);
      _watchCallStatus(callId, whileRinging: false);
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
      emit(
        UserCallWaitingForPeer(
          callId: callId,
          channelName: channelName,
          doctorName: doctorName,
        ),
      );
    } catch (e) {
      emit(UserCallError(e.toString()));
    }
  }

  Future<void> _onCallRejected(
    CallRejected event,
    Emitter<UserCallState> emit,
  ) async {
    if (_pendingCallId != null) {
      try {
        await _repository.rejectCall(callId: _pendingCallId!);
      } catch (_) {}
    }
    _clearPending();
    emit(const UserCallIdle());
  }

  void _onRemoteUserJoined(
    RemoteUserJoined event,
    Emitter<UserCallState> emit,
  ) {
    final callId = _getCallId(state);
    final channelName = _getChannelName(state);
    if (callId == null || channelName == null) return;
    emit(
      UserCallActive(
        callId: callId,
        channelName: channelName,
        doctorName: _getDoctorName(state),
        remoteUid: event.uid,
        isMuted: _getMuted(state),
        elapsedSeconds: _elapsedSeconds,
      ),
    );
  }

  void _onRemoteUserLeft(RemoteUserLeft event, Emitter<UserCallState> emit) =>
      emit(UserCallPeerLeft(elapsedSeconds: _elapsedSeconds));

  Future<void> _onCallEndRequested(
    CallEndRequested event,
    Emitter<UserCallState> emit,
  ) async {
    _stopTimer();
    await _callStatusSub?.cancel();
    _callStatusSub = null;
    final callId = _pendingCallId ?? _getCallId(state);
    if (callId != null) {
      try {
        await _repository.endCallDocument(callId: callId);
      } catch (_) {}
    }
    await _repository.leaveAndDispose();
    _clearPending();
    emit(const UserCallEnded());
    await Future.delayed(const Duration(seconds: 1));
    if (!isClosed) emit(const UserCallIdle());
  }

  Future<void> _onMuteToggled(
    CallMuteToggled event,
    Emitter<UserCallState> emit,
  ) async {
    final newMuted = !_getMuted(state);
    await _repository.muteLocalAudio(mute: newMuted);
    final s = state;
    if (s is UserCallActive) {
      emit(s.copyWith(isMuted: newMuted));
    } else if (s is UserCallWaitingForPeer) {
      emit(s.copyWith(isMuted: newMuted));
    }
  }

  Future<void> _onCameraSwitched(
    CallCameraSwitched event,
    Emitter<UserCallState> emit,
  ) => _repository.switchCamera();

  void _onTimerTicked(CallTimerTicked event, Emitter<UserCallState> emit) {
    _elapsedSeconds = event.seconds;
    final s = state;
    if (s is UserCallActive) {
      emit(s.copyWith(elapsedSeconds: event.seconds));
    } else if (s is UserCallWaitingForPeer) {
      emit(s.copyWith(elapsedSeconds: event.seconds));
    }
  }

  void _onErrorOccurred(CallErrorOccurred event, Emitter<UserCallState> emit) {
    _stopTimer();
    emit(UserCallError(event.message));
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
