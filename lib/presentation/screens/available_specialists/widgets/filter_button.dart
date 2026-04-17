// lib/presentation/screens/available_specialists/widgets/filter_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        final hasActiveFilters = state is DoctorLoaded &&
            state.filter.hasActiveFilters;
        final filterCount = state is DoctorLoaded
            ? state.filter.activeFilterCount
            : 0;

        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: hasActiveFilters
                    ? AppColors.primaryColor
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                elevation: hasActiveFilters ? 2 : 0,
                child: InkWell(
                  onTap: () {
                    // Capture the BLoC instance before opening bottom sheet
                    final doctorBloc = context.read<DoctorBloc>();
                    
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparentColor,
                      builder: (bottomSheetContext) => BlocProvider.value(
                        // Provide the existing DoctorBloc to the bottom sheet
                        value: doctorBloc,
                        child: const DoctorFilterBottomSheet(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasActiveFilters
                            ? AppColors.primaryColor
                            : AppColors.lightText,
                        width: hasActiveFilters ? 0 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune,
                          color: hasActiveFilters
                              ? AppColors.backgroundColor
                              : AppColors.lightTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: hasActiveFilters
                                ? AppColors.backgroundColor
                                : AppColors.lightTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (hasActiveFilters && filterCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.errorBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundColor, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$filterCount',
                        style: const TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}