import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/prescription_model.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/medicine_tile.dart';
import 'package:intl/intl.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final UserPrescriptionRecord record;

  const PrescriptionDetailScreen({required this.record, super.key});

  @override
  Widget build(BuildContext context) {
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
                  // ── Date & Time ─────────────────────────────────────────
                  _InfoRow(record: record),
                  const SizedBox(height: 24),

                  // ── Medications ─────────────────────────────────────────
                  _SectionHeader(
                    icon: Icons.medication_rounded,
                    title: 'Medications (${record.medications.length})',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  ...record.medications.asMap().entries.map(
                        (e) => MedicineTile(med: e.value, index: e.key + 1),
                      ),

                  // ── Doctor's Note ───────────────────────────────────────
                  if (record.docNote.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.notes_rounded,
                      title: "Doctor's Note",
                      color: AppColors.pending,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.pending.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        record.docNote,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: AppColors.gradientStart,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.white),

      // ✅ Title ONLY here — renders only when bar is fully collapsed
      title: const Text(
        'Prescription',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,

      flexibleSpace: FlexibleSpaceBar(
        // ✅ Pin mode — no parallax drift on scroll
        collapseMode: CollapseMode.pin,
        // ✅ NO title inside FlexibleSpaceBar — was the overlap cause
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative circles ────────────────────────────────────
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

              // ── Doctor info — below status bar + back button ──────────
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Extra top offset to clear the back button row
                      const SizedBox(height: 32),

                      // Doctor avatar
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                          image: (record.doctorProfileImageUrl != null &&
                                  record.doctorProfileImageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(
                                      record.doctorProfileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (record.doctorProfileImageUrl == null ||
                                record.doctorProfileImageUrl!.isEmpty)
                            ? Center(
                                child: Text(
                                  record.doctorName != null &&
                                          record.doctorName!.isNotEmpty
                                      ? record.doctorName![0].toUpperCase()
                                      : 'D',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Doctor name
                      Text(
                        record.doctorName != null
                            ? 'Dr. ${record.doctorName}'
                            : 'Doctor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      // Specialist
                      if (record.doctorSpecialist != null &&
                          record.doctorSpecialist!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            record.doctorSpecialist!,
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

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final UserPrescriptionRecord record;
  const _InfoRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: DateFormat('dd MMM yyyy').format(record.timestamp),
            color: AppColors.primary,
            surface: AppColors.primarySurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoChip(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: DateFormat('hh:mm a').format(record.timestamp),
            color: AppColors.confirmed,
            surface: AppColors.confirmedSurface,
          ),
        ),
      ],
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color surface;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}