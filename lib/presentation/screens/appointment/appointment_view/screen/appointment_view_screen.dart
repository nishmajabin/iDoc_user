import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appoinment_view_info_tile.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_divider.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_prescription_button.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_section_card.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_section_label.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_sliver_appbar.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view/widgets/appointment_view_status_banner.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/screens/prescription_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

class AppointmentViewScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentViewScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = appointment.status.toLowerCase();
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    final isConfirmed = status == 'confirmed';
    final showPrescription = isCompleted || isConfirmed;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        slivers: [
          AppointmentViewSliverAppBar(appointment: appointment),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status banner ─────────────────────────────────────
                  AppointmentViewStatusBanner(status: appointment.status),
                  const SizedBox(height: 20),

                  // ── Appointment info ──────────────────────────────────
                  const AppointmentViewSectionLabel(
                    icon: Icons.event_note_rounded,
                    title: 'Appointment Info',
                  ),
                  const SizedBox(height: 10),
                  AppointmentViewSectionCard(
                    child: Column(
                      children: [
                        AppoinmentViewInfoTile(
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.primary,
                          iconSurface: AppColors.primarySurface,
                          label: 'Date',
                          value: DateFormat(
                            'EEEE, dd MMMM yyyy',
                          ).format(appointment.appointmentDate),
                        ),
                        const AppointmentViewDivider(),
                        AppoinmentViewInfoTile(
                          icon: Icons.access_time_rounded,
                          iconColor: AppColors.confirmed,
                          iconSurface: AppColors.confirmedSurface,
                          label: 'Time',
                          value:
                              '${appointment.startTime}  →  ${appointment.endTime}',
                        ),
                        const AppointmentViewDivider(),
                        AppoinmentViewInfoTile(
                          icon: Icons.currency_rupee_rounded,
                          iconColor: AppColors.completed,
                          iconSurface: AppColors.completedSurface,
                          label: 'Consultation Fee',
                          value:
                              '₹${appointment.consultationFee?.toStringAsFixed(0) ?? '0'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Patient details ───────────────────────────────────
                  const AppointmentViewSectionLabel(
                    icon: Icons.person_outline_rounded,
                    title: 'Patient Details',
                  ),
                  const SizedBox(height: 10),
                  AppointmentViewSectionCard(
                    child: Column(
                      children: [
                      AppoinmentViewInfoTile(
                          icon: Icons.badge_outlined,
                          iconColor: AppColors.primary,
                          iconSurface: AppColors.primarySurface,
                          label: 'Patient Name',
                          value: appointment.patientName,
                        ),
                        if (appointment.contactNumber.isNotEmpty) ...[
                          const AppointmentViewDivider(),
                          AppoinmentViewInfoTile(
                            icon: Icons.phone_outlined,
                            iconColor: AppColors.completed,
                            iconSurface: AppColors.completedSurface,
                            label: 'Contact',
                            value: appointment.contactNumber,
                          ),
                        ],
                        if (appointment.description.isNotEmpty) ...[
                          const AppointmentViewDivider(),
                          AppoinmentViewInfoTile(
                            icon: Icons.notes_rounded,
                            iconColor: AppColors.pending,
                            iconSurface: AppColors.pendingSurface,
                            label: 'Reason',
                            value: appointment.description,
                            isMultiLine: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Prescription button ───────────────────────────────
                  if (showPrescription) ...[
                    AppointmentViewPrescriptionButton(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PrescriptionListScreen(
                                    userId: appointment.userId,
                                  ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Cancelled note ────────────────────────────────────
                  if (isCancelled)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cancelledSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.cancelled.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.cancelled,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This appointment was cancelled. The slot has been released.',
                              style: TextStyle(
                                color: AppColors.cancelled.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

