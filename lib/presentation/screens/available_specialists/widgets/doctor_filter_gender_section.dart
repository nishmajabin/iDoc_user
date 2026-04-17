import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_chip.dart';

class DoctorFilterGenderSection extends StatelessWidget {
  const DoctorFilterGenderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) => prev.filter.gender != curr.filter.gender,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Gender Preference',
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
              children: [
                ...DoctorFilterBottomSheet.genderOptions
                    .map((gender) => buildDoctorFilterChip(
                          context,
                          gender,
                          state.filter.gender == gender,
                          (selected) {
                            context
                                .read<DoctorFilterCubit>()
                                .updateGender(gender, selected);
                          },
                        )),
                buildDoctorFilterChip(
                  context,
                  'No Preference',
                  state.filter.gender == null,
                  (selected) {
                    if (selected) {
                      context.read<DoctorFilterCubit>().clearGender();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}