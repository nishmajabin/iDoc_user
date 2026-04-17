  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/custom_build_chip.dart';

List<Widget> buildFilterChips(BuildContext context, DoctorFilter filter) {
    final chips = <Widget>[];

  // Consultation fee
    if (filter.minFee != null || filter.maxFee != null) {
      final min = filter.minFee?.round() ?? 0;
      final max = filter.maxFee?.round() ?? 5000;
            
      if (min != 0 || max != 5000) {
        chips.add(buildChip(
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
      chips.add(buildChip(
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
      chips.add(buildChip(
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
      chips.add(buildChip(
        context,
        exp,
        Icons.work_outline,
        () {
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
      chips.add(buildChip(
        context,
        'Available Today',
        Icons.calendar_today,
        () {
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(availableToday: false),
              ));
        },
      ));
    }

    if (filter.availableThisWeek) {
      chips.add(buildChip(
        context,
        'Available This Week',
        Icons.calendar_month,
        () {
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(availableThisWeek: false),
              ));
        },
      ));
    }

    // Gender chip
    if (filter.gender != null) {
      chips.add(buildChip(
        context,
        filter.gender!,
        Icons.person_outline,
        () {
          context.read<DoctorBloc>().add(ApplyFiltersEvent(
                filter.copyWith(clearGender: true),
              ));
        },
      ));
    }
    return chips;
  }