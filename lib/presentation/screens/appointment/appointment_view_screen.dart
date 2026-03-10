import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/prescription_list_screen.dart';
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
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status banner ─────────────────────────────────────
                  _StatusBanner(status: appointment.status),
                  const SizedBox(height: 20),

                  // ── Appointment info ──────────────────────────────────
                  const _SectionLabel(
                    icon: Icons.event_note_rounded,
                    title: 'Appointment Info',
                  ),
                  const SizedBox(height: 10),
                  _SectionCard(
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.primary,
                          iconSurface: AppColors.primarySurface,
                          label: 'Date',
                          value: DateFormat(
                            'EEEE, dd MMMM yyyy',
                          ).format(appointment.appointmentDate),
                        ),
                        const _Divider(),
                        _InfoTile(
                          icon: Icons.access_time_rounded,
                          iconColor: AppColors.confirmed,
                          iconSurface: AppColors.confirmedSurface,
                          label: 'Time',
                          value:
                              '${appointment.startTime}  →  ${appointment.endTime}',
                        ),
                        const _Divider(),
                        _InfoTile(
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
                  const _SectionLabel(
                    icon: Icons.person_outline_rounded,
                    title: 'Patient Details',
                  ),
                  const SizedBox(height: 10),
                  _SectionCard(
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.badge_outlined,
                          iconColor: AppColors.primary,
                          iconSurface: AppColors.primarySurface,
                          label: 'Patient Name',
                          value: appointment.patientName,
                        ),
                        if (appointment.contactNumber.isNotEmpty) ...[
                          const _Divider(),
                          _InfoTile(
                            icon: Icons.phone_outlined,
                            iconColor: AppColors.completed,
                            iconSurface: AppColors.completedSurface,
                            label: 'Contact',
                            value: appointment.contactNumber,
                          ),
                        ],
                        if (appointment.description.isNotEmpty) ...[
                          const _Divider(),
                          _InfoTile(
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
                    _PrescriptionButton(
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

  // ── Sliver AppBar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: AppColors.gradientStart,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),
      // ✅ Title ONLY here — only visible when collapsed, never overlaps
      title: const Text(
        'Appointment Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Doctor info
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      // Avatar
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                          image:
                              (appointment.doctorProfileImageUrl != null &&
                                      appointment
                                          .doctorProfileImageUrl!
                                          .isNotEmpty)
                                  ? DecorationImage(
                                    image: NetworkImage(
                                      appointment.doctorProfileImageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            (appointment.doctorProfileImageUrl == null ||
                                    appointment.doctorProfileImageUrl!.isEmpty)
                                ? const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dr. ${appointment.doctorName ?? 'Doctor'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (appointment.doctorSpecialist != null &&
                          appointment.doctorSpecialist!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointment.doctorSpecialist!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    final Color bg, border, textColor, iconColor;
    final IconData icon;
    final String label;

    if (s == 'completed') {
      bg = AppColors.completedSurface;
      border = AppColors.completed.withValues(alpha: 0.35);
      textColor = AppColors.completed;
      iconColor = AppColors.completed;
      icon = Icons.check_circle_rounded;
      label = 'Appointment Completed';
    } else if (s == 'cancelled') {
      bg = AppColors.cancelledSurface;
      border = AppColors.cancelled.withValues(alpha: 0.35);
      textColor = AppColors.cancelled;
      iconColor = AppColors.cancelled;
      icon = Icons.cancel_rounded;
      label = 'Appointment Cancelled';
    } else if (s == 'confirmed') {
      bg = AppColors.confirmedSurface;
      border = AppColors.confirmed.withValues(alpha: 0.35);
      textColor = AppColors.confirmed;
      iconColor = AppColors.confirmed;
      icon = Icons.event_available_rounded;
      label = 'Appointment Confirmed';
    } else {
      bg = AppColors.pendingSurface;
      border = AppColors.pending.withValues(alpha: 0.35);
      textColor = AppColors.pending;
      iconColor = AppColors.pending;
      icon = Icons.schedule_rounded;
      label = 'Pending Confirmation';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String label;
  final String value;
  final bool isMultiLine;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconSurface,
    required this.label,
    required this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.divider);
  }
}

// ── Prescription Button ───────────────────────────────────────────────────────

class _PrescriptionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PrescriptionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'View Prescription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
