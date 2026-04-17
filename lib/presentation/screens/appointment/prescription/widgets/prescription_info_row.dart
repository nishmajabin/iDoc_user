
import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/prescription_model.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_info_chip.dart';
import 'package:intl/intl.dart';

class PrescriptionInfoRow extends StatelessWidget {
  final UserPrescriptionRecord record;
  const PrescriptionInfoRow({required this.record, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrescriptionInfoChip(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: DateFormat('dd MMM yyyy').format(record.timestamp),
            color: AppColors.primary,
            surface: AppColors.primarySurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrescriptionInfoChip(
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
