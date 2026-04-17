import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_ui_state.dart';

/// Translates raw [UserCallState] domain events into [VideoCallUiState]
/// commands that [UserVideoCallScreen] reacts to.
///
/// ### Responsibilities
/// - Map every relevant [UserCallState] to a typed [VideoCallUiState].
/// - Carry only the data the UI needs (doctor name, mute flag, elapsed time,
///   remote uid, channel name) — no Flutter widgets, no SDK handles.
/// - Deduplicate timer ticks so [BlocBuilder] is not triggered every second
///   for the full subtree — only [_TimerBadge] rebuilds on ticks.
///
/// ### What this cubit does NOT do
/// - It does not hold [Widget] references (those belong to [_VideoViewCache]).
/// - It does not call [UserCallBloc] — it is read-only, fed by the UI layer's
///   [BlocListener] bridge (same pattern as [CallListenerCubit]).
class VideoCallCubit extends Cubit<VideoCallUiState> {
  VideoCallCubit() : super(const VideoCallUiConnecting(doctorName: 'Doctor'));

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called by the [BlocListener] bridge in [UserVideoCallScreen] every time
  /// [UserCallBloc] emits a new state.
  void onUserCallStateChanged(UserCallState callState) {
    switch (callState) {
      case UserCallConnecting():
        emit(VideoCallUiConnecting(doctorName: callState.doctorName));

      case UserCallWaitingForPeer():
        // Preserve mute/elapsed if we are already in Waiting (avoids
        // discarding in-progress timer data on a no-op transition).
        final current = state;
        if (current is VideoCallUiWaiting) {
          emit(current.copyWith(
            isMuted: callState.isMuted,
            elapsedSeconds: callState.elapsedSeconds,
          ));
        } else {
          emit(VideoCallUiWaiting(
            doctorName: callState.doctorName,
            channelName: callState.channelName,
            isMuted: callState.isMuted,
            elapsedSeconds: callState.elapsedSeconds,
          ));
        }

      case UserCallActive():
        final current = state;
        if (current is VideoCallUiActive &&
            current.remoteUid == callState.remoteUid) {
          // Only propagate fields that actually changed.
          emit(current.copyWith(
            isMuted: callState.isMuted,
            elapsedSeconds: callState.elapsedSeconds,
          ));
        } else {
          emit(VideoCallUiActive(
            doctorName: callState.doctorName,
            channelName: callState.channelName,
            remoteUid: callState.remoteUid,
            isMuted: callState.isMuted,
            elapsedSeconds: callState.elapsedSeconds,
          ));
        }

      case UserCallPeerLeft():
        emit(VideoCallUiPeerLeft(elapsedSeconds: callState.elapsedSeconds));

      case UserCallEnded():
        emit(const VideoCallUiEnded());

      case UserCallError():
        emit(VideoCallUiError(message: callState.message));

      // UserCallIdle / UserCallRinging are not reachable from inside the
      // video-call screen — ignore them.
      default:
        break;
    }
  }
}