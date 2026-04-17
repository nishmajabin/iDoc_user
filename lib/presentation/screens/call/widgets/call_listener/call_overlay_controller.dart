import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/cubits/call_listener/call_listener_state.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/screen/incoming_call_screen.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/screen/user_video_call_screen.dart';

class CallOverlayController {
  OverlayEntry? _incomingCallOverlay;
  bool _isVideoCallScreenPushed = false;

  void showIncomingCallOverlay(
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey,
    CallListenerShowIncomingCall state,
  ) {
    if (_incomingCallOverlay != null) return;

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint(
          ' [CallListenerWrapper] No OverlayState — cannot show incoming call');
      return;
    }

    debugPrint(
        '[CallListenerWrapper] Showing incoming call overlay for ${state.doctorName}');

    _incomingCallOverlay = OverlayEntry(
      builder: (_) => IncomingCallScreen(
        doctorName: state.doctorName,
        doctorProfileImageUrl: state.doctorProfileImageUrl,
        onAccept: () {
          debugPrint(' [CallListenerWrapper] User accepted call');
          context.read<UserCallBloc>().add(const CallAccepted());
        },
        onReject: () {
          debugPrint(' [CallListenerWrapper] User rejected call');
          context.read<UserCallBloc>().add(const CallRejected());
        },
      ),
    );

    overlayState.insert(_incomingCallOverlay!);
  }

  void removeIncomingCallOverlay() {
    _incomingCallOverlay?.remove();
    _incomingCallOverlay = null;
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void pushVideoCallScreen(
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    if (_isVideoCallScreenPushed) return;
    _isVideoCallScreenPushed = true;

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      debugPrint(
          ' [CallListenerWrapper] No NavigatorState — cannot push video call');
      _isVideoCallScreenPushed = false;
      return;
    }

    debugPrint('🎥 [CallListenerWrapper] Pushing UserVideoCallScreen');

    navigator
        .push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UserCallBloc>(),
          child: const UserVideoCallScreen(),
        ),
      ),
    )
        .then((_) {
      _isVideoCallScreenPushed = false;
    });
  }
}