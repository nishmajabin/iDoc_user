import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart';

class DoctorFilterConsultationFeeSection extends StatelessWidget {
  const DoctorFilterConsultationFeeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) => prev.feeRange != curr.feeRange,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Consultation Fee',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${state.feeRange.start.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${state.feeRange.end.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: state.feeRange,
              min: DoctorFilterBottomSheet.minFee,
              max: DoctorFilterBottomSheet.maxFee,
              divisions: 50,
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.primaryColor.withValues(alpha: 0.2),
              labels: RangeLabels(
                '₹${state.feeRange.start.round()}',
                '₹${state.feeRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                context.read<DoctorFilterCubit>().updateFeeRange(values);
              },
            ),
          ],
        );
      },
    );
  }
}