import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/appointment_card_cancel_button.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/appointment_card_doctor_avatar.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/appointment_card_status_badge.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appoinment_meta_chip.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/status_style.dart';
import 'package:intl/intl.dart';

class MyAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isUpcoming;
  final VoidCallback onTap, onCancel;
 
  const MyAppointmentCard({
    required this.appointment,
    required this.isUpcoming,
    required this.onTap,
    required this.onCancel,
    super.key,
  });
 
  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(appointment.status);
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';
 
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
 
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor row
                  Row(
                    children: [
                      AppointmentCardDoctorAvatar(
                          imageUrl: appointment.doctorProfileImageUrl,
                          name: appointment.doctorName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${appointment.doctorName ?? 'Doctor'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appointment.doctorSpecialist ?? 'Consultation',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      AppointmentCardStatusBadge(style),
                    ],
                  ),
 
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 14),
 
                  // Date / Time chips
                  Row(
                    children: [
                     MyAppoinmentMetaChip(
                        icon: Icons.calendar_today_rounded,
                        value: DateFormat('dd MMM yyyy')
                            .format(appointment.appointmentDate),
                        color: AppColors.primary,
                        surface: AppColors.primarySurface,
                      ),
                      const SizedBox(width: 10),
                      MyAppoinmentMetaChip(
                        icon: Icons.access_time_rounded,
                        value: formatTimeTo12Hour(appointment.startTime),
                        color: AppColors.accent,
                        surface: AppColors.confirmedSurface,
                      ),
                    ],
                  ),
 
                  if (isUpcoming && !isCancelled) ...[
                    const SizedBox(height: 14),
                    AppointmentCardCancelButton(onTap: onCancel),
                  ],
 
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('View details',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500)),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}