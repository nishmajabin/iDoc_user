import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';
import 'package:idoc_user/logic/cubits/call_listener/call_listener_state.dart';

/// Translates [UserCallBloc] state changes into [CallListenerState] commands
/// that the UI layer can react to.
///
/// This cubit contains **zero Flutter / UI imports** — all it does is map
/// domain states to UI-intent states.  The [CallListenerWrapper] feeds it
/// [UserCallState] values by calling [onUserCallStateChanged].
///
/// ### Why a Cubit and not a plain Bloc?
/// There are no complex async events here — the cubit receives a synchronous
/// callback from the BlocListener and emits the appropriate command state.
/// A Cubit is the right tool for this simple mapping.
class CallListenerCubit extends Cubit<CallListenerState> {
  CallListenerCubit() : super(const CallListenerIdle());

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called by [CallListenerWrapper]'s [BlocListener] every time
  /// [UserCallBloc] emits a new state.
  void onUserCallStateChanged(UserCallState callState) {
    switch (callState) {
      case UserCallRinging():
        _handleRinging(callState);

      case UserCallConnecting():
        // User accepted — dismiss overlay then navigate.
        // We emit DismissOverlay first so the listener removes the overlay
        // before we try to push a new route.  A second emit immediately
        // after triggers the navigation.
        emit(const CallListenerDismissOverlay());
        emit(const CallListenerNavigateToVideoCall());

      case UserCallIdle():
      case UserCallEnded():
      case UserCallError():
        emit(const CallListenerDismissOverlay());

      // Active / WaitingForPeer / PeerLeft are purely internal video-call
      // states — the wrapper does not need to react to them.
      default:
        break;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _handleRinging(UserCallRinging ringing) {
    final currentState = state;

    // Avoid re-emitting the same overlay for the same call (dedup).
    if (currentState is CallListenerShowIncomingCall &&
        currentState.callId == ringing.callId) {
      return;
    }

    emit(CallListenerShowIncomingCall(
      callId: ringing.callId,
      doctorName: ringing.doctorName,
      doctorProfileImageUrl: ringing.doctorProfileImageUrl,
    ));
  }
}