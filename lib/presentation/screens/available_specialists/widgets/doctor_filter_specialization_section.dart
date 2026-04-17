import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_chip.dart';

class DoctorFilterSpecializationSection extends StatelessWidget {
  const DoctorFilterSpecializationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorFilterCubit, DoctorFilterSheetState>(
      buildWhen: (prev, curr) =>
          prev.filter.specializations != curr.filter.specializations,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Specialization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DoctorFilterBottomSheet.specializations
                  .map((spec) => buildDoctorFilterChip(
                        context,
                        spec,
                        state.filter.specializations.contains(spec),
                        (selected) {
                          context
                              .read<DoctorFilterCubit>()
                              .toggleSpecialization(spec, selected);
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