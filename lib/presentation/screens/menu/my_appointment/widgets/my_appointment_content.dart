import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_event.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_state.dart';
import 'package:idoc_user/logic/cubits/my_appointment/appointment_tab_cubit.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/screen/appointment_view_screen.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appoinment_card.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_cancel_dialog.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_empty_state.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_error_view.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_shimmer_list.dart';

class MyAppointmentContent extends StatelessWidget {
  final String userId;

  const MyAppointmentContent({required this.userId, super.key});

  void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? AppColors.cancelled : AppColors.completed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) => MyAppointmentCancelDialog(
        appointment: appointment,
        userId: userId,
        // Pass the parent bloc so the dialog can dispatch events even after
        // the dialog's own context is popped.
        appointmentsBloc: context.read<AppointmentsListBloc>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsListBloc, AppointmentsListState>(
      listener: (context, state) {
        if (state is AppointmentCancelled) {
          _showSnackBar(context, state.message, isError: false);
        } else if (state is AppointmentsListError) {
          _showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        // Loading / cancelling → shimmer
        if (state is AppointmentsListLoading ||
            state is AppointmentCancelling) {
          return const MyAppointmentShimmerList();
        }

        if (state is AppointmentsListError) {
          return MyAppointmentErrorView(
            message: state.message,
            onRetry: () => context
                .read<AppointmentsListBloc>()
                .add(FetchUserAppointmentsEvent(userId)),
          );
        }

        if (state is AppointmentsListLoaded) {
          // Tab state drives which list to show — no setState needed
          return BlocBuilder<AppointmentTabCubit, bool>(
            builder: (context, isUpcoming) {
              final appointments = isUpcoming
                  ? state.upcomingAppointments
                  : state.pastAppointments;

              if (appointments.isEmpty) {
                return MyAppointmentEmptyState(isUpcoming: isUpcoming);
              }

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.cardBg,
                onRefresh: () async {
                  context
                      .read<AppointmentsListBloc>()
                      .add(RefreshAppointmentsEvent(userId));
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) => MyAppointmentCard(
                    appointment: appointments[index],
                    isUpcoming: isUpcoming,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentViewScreen(
                          appointment: appointments[index],
                        ),
                      ),
                    ),
                    onCancel: () =>
                        _showCancelDialog(context, appointments[index]),
                  ),
                ),
              );
            },
          );
        }

        // Initial / unknown state → empty
        return BlocBuilder<AppointmentTabCubit, bool>(
          builder: (context, isUpcoming) =>
              MyAppointmentEmptyState(isUpcoming: isUpcoming),
        );
      },
    );
  }
}