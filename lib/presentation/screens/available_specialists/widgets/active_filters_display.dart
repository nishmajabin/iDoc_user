// lib/presentation/screens/available_specialists/widgets/active_filters_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

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
        final chips = _buildFilterChips(context, filter);

        if (chips.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.white,
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
                      color: Colors.grey[700],
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterChips(BuildContext context, DoctorFilter filter) {
    final chips = <Widget>[];

// Consultation fee
    if (filter.minFee != null || filter.maxFee != null) {
      final min = filter.minFee?.round() ?? 0;
      final max = filter.maxFee?.round() ?? 5000;
            
      if (min != 0 || max != 5000) {
        chips.add(_buildChip(
          context,
          '₹$min - ₹$max',
          Icons.account_balance_wallet,
          () {
            final updatedFilter = DoctorFilter(
              minRating: filter.minRating,
              specializations: filter.specializations,
              experienceRanges: filter.experienceRanges,
              availableToday: filter.availableToday,
              availableThisWeek: filter.availableThisWeek,
              gender: filter.gender,
            );
            context.read<DoctorBloc>().add(ApplyFiltersEvent(updatedFilter));
          },
        ));
      } else {
      }
    }

    // Ratings 
    if (filter.minRating != null) {
      chips.add(_buildChip(
        context,
        '${filter.minRating!.toInt()}★ & above',
        Icons.star,
        () {
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(minRating: null),
              ));
        },
      ));
    }

    // Specialization
    for (var spec in filter.specializations) {
      chips.add(_buildChip(
        context,
        spec,
        Icons.medical_services,
        () {
          final updated = List<String>.from(filter.specializations)
            ..remove(spec);
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(specializations: updated),
              ));
        },
      ));
    }

    // Experience 
    for (var exp in filter.experienceRanges) {
      print('   ✅ Adding exp chip: $exp');
      chips.add(_buildChip(
        context,
        exp,
        Icons.work_outline,
        () {
          print('👆 Removing experience: $exp');
          final updated = List<String>.from(filter.experienceRanges)
            ..remove(exp);
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(experienceRanges: updated),
              ));
        },
      ));
    }

    // Availability chips
    if (filter.availableToday) {
      print('   ✅ Adding available today chip');
      chips.add(_buildChip(
        context,
        'Available Today',
        Icons.calendar_today,
        () {
          print('👆 Removing available today');
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(availableToday: false),
              ));
        },
      ));
    }

    if (filter.availableThisWeek) {
      print('   ✅ Adding available week chip');
      chips.add(_buildChip(
        context,
        'Available This Week',
        Icons.calendar_month,
        () {
          print('👆 Removing available week');
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(availableThisWeek: false),
              ));
        },
      ));
    }

    // Gender chip
    if (filter.gender != null) {
      print('   ✅ Adding gender chip: ${filter.gender}');
      chips.add(_buildChip(
        context,
        filter.gender!,
        Icons.person_outline,
        () {
          print('👆 Removing gender filter');
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(clearGender: true),
              ));
        },
      ));
    }

    print('   📊 Total chips: ${chips.length}');
    return chips;
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
