import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';
import 'package:idoc_user/presentation/screens/call/incoming_call_screen.dart';
import 'package:idoc_user/presentation/screens/call/user_video_call_screen.dart';

/// Wraps the entire app navigator and reacts to [UserCallBloc] state changes
/// to show the incoming-call overlay or push the video-call screen.
///
/// This widget is placed inside `MaterialApp.builder` so it lives above all
/// routes and is never removed by navigation. It uses the shared
/// [navigatorKey] to push/overlay screens on the root navigator.
class CallListenerWrapper extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const CallListenerWrapper({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<CallListenerWrapper> createState() => _CallListenerWrapperState();
}

class _CallListenerWrapperState extends State<CallListenerWrapper> {
  OverlayEntry? _incomingCallOverlay;
  bool _isVideoCallScreenPushed = false;

  @override
  void dispose() {
    _removeIncomingCallOverlay();
    super.dispose();
  }

  // ── Overlay helpers ───────────────────────────────────────────────────────

  void _showIncomingCallOverlay(UserCallRinging state) {
    // Don't show duplicate overlays.
    if (_incomingCallOverlay != null) return;

    final overlayState =
        widget.navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint(
          '⚠️ [CallListenerWrapper] No OverlayState — cannot show incoming call');
      return;
    }

    debugPrint(
        '📞 [CallListenerWrapper] Showing incoming call overlay for ${state.doctorName}');

    _incomingCallOverlay = OverlayEntry(
      builder: (_) => IncomingCallScreen(
        doctorName: state.doctorName,
        doctorProfileImageUrl: state.doctorProfileImageUrl,
        onAccept: () {
          debugPrint('✅ [CallListenerWrapper] User accepted call');
          context.read<UserCallBloc>().add(const CallAccepted());
        },
        onReject: () {
          debugPrint('❌ [CallListenerWrapper] User rejected call');
          context.read<UserCallBloc>().add(const CallRejected());
        },
      ),
    );

    overlayState.insert(_incomingCallOverlay!);
  }

  void _removeIncomingCallOverlay() {
    _incomingCallOverlay?.remove();
    _incomingCallOverlay = null;
  }

  void _pushVideoCallScreen() {
    if (_isVideoCallScreenPushed) return;
    _isVideoCallScreenPushed = true;

    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) {
      debugPrint(
          '⚠️ [CallListenerWrapper] No NavigatorState — cannot push video call');
      _isVideoCallScreenPushed = false;
      return;
    }

    debugPrint('🎥 [CallListenerWrapper] Pushing UserVideoCallScreen');

    navigator
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UserCallBloc>(),
          child: const UserVideoCallScreen(),
        ),
      ),
    )
        .then((_) {
      // When the video call screen pops, mark it as no longer pushed.
      _isVideoCallScreenPushed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCallBloc, UserCallState>(
      listener: (context, state) {
        debugPrint(
            '🔔 [CallListenerWrapper] State: ${state.runtimeType}');

        if (state is UserCallRinging) {
          // Show the incoming call overlay.
          _showIncomingCallOverlay(state);
        } else if (state is UserCallConnecting) {
          // User accepted → remove overlay, push video call screen.
          _removeIncomingCallOverlay();
          _pushVideoCallScreen();
        } else if (state is UserCallIdle) {
          // Call ended or was cancelled — clean up everything.
          _removeIncomingCallOverlay();
        } else if (state is UserCallEnded) {
          _removeIncomingCallOverlay();
        } else if (state is UserCallError) {
          _removeIncomingCallOverlay();
        }
      },
      child: widget.child,
    );
  }
}
