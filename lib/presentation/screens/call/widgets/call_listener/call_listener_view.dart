import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';
import 'package:idoc_user/logic/cubits/call_listener/call_listener_cubit.dart';
import 'package:idoc_user/logic/cubits/call_listener/call_listener_state.dart';
import 'package:idoc_user/presentation/screens/call/widgets/call_listener/call_overlay_controller.dart';

class CallListenerView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  final CallOverlayController _controller;

  const CallListenerView({
    required this.navigatorKey,
    required this.child,
    required CallOverlayController controller,
    super.key
    
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // forward UserCallBloc state → CallListenerCubit.
        BlocListener<UserCallBloc, UserCallState>(
          listener: (context, callState) {
            debugPrint(
                '🔔 [CallListenerWrapper] UserCallBloc state: ${callState.runtimeType}');
            context
                .read<CallListenerCubit>()
                .onUserCallStateChanged(callState);
          },
        ),

        // CallListenerCubit command states → overlay / navigation.
        BlocListener<CallListenerCubit, CallListenerState>(
          listener: (context, listenerState) {
            debugPrint(
                '🎛️ [CallListenerWrapper] CallListenerCubit state: ${listenerState.runtimeType}');

            switch (listenerState) {
              case CallListenerShowIncomingCall():
                _controller.showIncomingCallOverlay(
                    context, navigatorKey, listenerState);

              case CallListenerNavigateToVideoCall():
                _controller.pushVideoCallScreen(context, navigatorKey);

              case CallListenerDismissOverlay():
                _controller.removeIncomingCallOverlay();

              case CallListenerIdle():
                break;
            }
          },
        ),
      ],
      child: child,
    );
  }
}