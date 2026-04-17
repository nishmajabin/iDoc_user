import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';

class DoctorFilterRatingSection extends StatelessWidget {
  const DoctorFilterRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) =>
          prev.selectedRating != curr.selectedRating,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Minimum Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildRatingChip(context, '4★ & above', 4.0, state),
                _buildRatingChip(context, '3★ & above', 3.0, state),
                _buildRatingChip(context, '2★ & above', 2.0, state),
                _buildRatingChip(context, 'All Ratings', null, state),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRatingChip(
    BuildContext context,
    String label,
    double? rating,
    DoctorFilterSheetState state,
  ) {
    final isSelected = state.selectedRating == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<DoctorFilterCubit>().updateRating(rating, selected);
      },
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : AppColors.lightTextColor2,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : AppColors.lightTextColor,
      ),
    );
  }
}
