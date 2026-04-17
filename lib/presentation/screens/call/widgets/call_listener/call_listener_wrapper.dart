import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/call_listener/call_listener_cubit.dart';
import 'package:idoc_user/presentation/screens/call/widgets/call_listener/call_listener_view.dart';
import 'package:idoc_user/presentation/screens/call/widgets/call_listener/call_overlay_controller.dart';

class CallListenerWrapper extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const CallListenerWrapper({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    final controller = CallOverlayController();

    return BlocProvider<CallListenerCubit>(
      create: (_) => CallListenerCubit(),
      child: CallListenerView(
        navigatorKey: navigatorKey,
        controller: controller,
        child: child,
      ),
    );
  }
}
