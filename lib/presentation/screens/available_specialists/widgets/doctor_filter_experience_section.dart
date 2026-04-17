import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_chip.dart';

class DoctorFilterExperienceSection extends StatelessWidget {
  const DoctorFilterExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) =>
          prev.filter.experienceRanges != curr.filter.experienceRanges,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Experience',
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
              children: DoctorFilterBottomSheet.experienceRanges
                  .map((range) => buildDoctorFilterChip(
                        context,
                        range,
                        state.filter.experienceRanges.contains(range),
                        (selected) {
                          context
                              .read<DoctorFilterCubit>()
                              .toggleExperienceRange(range, selected);
                        },
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}