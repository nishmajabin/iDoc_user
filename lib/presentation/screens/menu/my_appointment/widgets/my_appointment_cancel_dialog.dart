import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_event.dart';

class MyAppointmentCancelDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final String userId;
  final AppointmentsListBloc appointmentsBloc;

  const MyAppointmentCancelDialog({
    required this.appointment,
    required this.userId,
    required this.appointmentsBloc,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.cancelledSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: AppColors.cancelled,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancel Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to cancel this appointment? '
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Keep It',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      appointmentsBloc.add(
                        CancelAppointmentEvent(
                          appointmentId: appointment.appointmentId!,
                          doctorId: appointment.doctorId,
                          slotId: appointment.slotId,
                          userId: userId,
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.cancelled,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Yes, Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
