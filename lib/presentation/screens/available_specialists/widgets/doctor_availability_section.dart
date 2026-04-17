import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';

class DoctorAvailabilitySection extends StatelessWidget {
  const DoctorAvailabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) =>
          prev.filter.availableToday != curr.filter.availableToday ||
          prev.filter.availableThisWeek != curr.filter.availableThisWeek,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              'Available Today',
              state.filter.availableToday,
              (value) {
                context.read<DoctorFilterCubit>().updateAvailableToday(value);
              },
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              'Available This Week',
              state.filter.availableThisWeek,
              (value) {
                context
                    .read<DoctorFilterCubit>()
                    .updateAvailableThisWeek(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textFieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightText),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextColor2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}