import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/filter_chips.dart';

class ActiveFiltersDisplay extends StatelessWidget {
  const ActiveFiltersDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      buildWhen: (previous, current) {
        if (previous is DoctorLoaded && current is DoctorLoaded) {
          final shouldRebuild = previous.filter != current.filter;
          return shouldRebuild;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! DoctorLoaded) {
          return const SizedBox.shrink();
        }
        if (!state.filter.hasActiveFilters) {
          return const SizedBox.shrink();
        }

        final filter = state.filter;
        final chips = buildFilterChips(context, filter);

        if (chips.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: AppColors.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Filters (${filter.activeFilterCount})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<DoctorBloc>().add(ClearFiltersEvent());
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 30),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: chips),
            ],
          ),
        );
      },
    );
  }
}
