import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/prescription_model.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/medicine_tile.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_info_row.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_section_header.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_sliver_appbar.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final UserPrescriptionRecord record;

  const PrescriptionDetailScreen({required this.record, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        slivers: [
         PrescriptionSliverAppbar(record: record),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date & Time ─────────────────────────────────────────
                  PrescriptionInfoRow(record: record),
                  const SizedBox(height: 24),

                  // ── Medications ─────────────────────────────────────────
                  PrescriptionSectionHeader(
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
                    PrescriptionSectionHeader(
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

}

