import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/prescription_model.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/medicine_tile_chip.dart';

class MedicineTile extends StatelessWidget {
  final PrescriptionMedication med;
  final int index;

  const MedicineTile({required this.med, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index badge
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                '$index',
                style:  TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.medication,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    MedicineTileChip(
                      icon: Icons.medication_outlined,
                      label: '${med.dosage} Tablet',
                      color: AppColors.primary,
                      surface: AppColors.primarySurface,
                    ),
                    MedicineTileChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${med.duration} ${med.durationUnit}',
                      color: AppColors.confirmed,
                      surface: AppColors.confirmedSurface,
                    ),
                    MedicineTileChip(
                      icon: Icons.repeat_rounded,
                      label: med.repeat,
                      color: AppColors.completed,
                      surface: AppColors.completedSurface,
                    ),
                    MedicineTileChip(
                      icon: Icons.wb_sunny_outlined,
                      label: med.timeOfDay,
                      color: AppColors.pending,
                      surface: AppColors.pendingSurface,
                    ),
                    MedicineTileChip(
                      icon: Icons.restaurant_outlined,
                      label: med.beTaken,
                      color: AppColors.cancelled,
                      surface: AppColors.cancelledSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

