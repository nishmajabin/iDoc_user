import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_event.dart' show FetchUserAppointmentsEvent;
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_content.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_header.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_tab_bar.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_unauthenticated_screen.dart';

class MyAppointmentsView extends StatelessWidget {
  const MyAppointmentsView({super.key});

  // ── bootstrap: fetch appointments once auth is resolved ───────────────────
  void _loadAppointments(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<AppointmentsListBloc>()
          .add(FetchUserAppointmentsEvent(authState.user.uid));
    }
  }

  String? userId(BuildContext context) {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.uid : null;
  }

  @override
  Widget build(BuildContext context) {
    // Trigger load on first build (equivalent to initState addPostFrameCallback)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments(context));

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return MyAppointmentUnauthenticatedScreen();
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.bgBase,
            body: Column(
              children: [
                const MyAppointmentHeader(),
                const MyAppointmentTabBar(),
                Expanded(
                  child: MyAppointmentContent(userId: authState.user.uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}