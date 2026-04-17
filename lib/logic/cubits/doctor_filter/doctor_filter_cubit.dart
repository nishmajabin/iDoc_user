import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_state.dart';

class DoctorFilterCubit extends Cubit<DoctorFilterSheetState> {
  DoctorFilterCubit() : super(const DoctorFilterSheetState());

  /// Initialize the cubit with an existing filter from the DoctorBloc state.
  void initialize(DoctorFilter existingFilter) {
    emit(DoctorFilterSheetState(
      filter: existingFilter,
      feeRange: RangeValues(
        existingFilter.minFee ?? 0,
        existingFilter.maxFee ?? 5000,
      ),
      selectedRating: existingFilter.minRating,
    ));
  }

  // ── Fee Range ───────────────────────────────────────────────────────

  void updateFeeRange(RangeValues values) {
    final updatedFilter = state.filter.copyWith(
      minFee: values.start,
      maxFee: values.end,
    );
    emit(state.copyWith(
      filter: updatedFilter,
      feeRange: values,
    ));
  }

  // ── Rating ──────────────────────────────────────────────────────────

  void updateRating(double? rating, bool selected) {
    final newRating = selected ? rating : null;
    final updatedFilter = state.filter.copyWith(minRating: newRating);
    emit(state.copyWith(
      filter: updatedFilter,
      selectedRating: newRating,
      clearRating: newRating == null,
    ));
  }

  // ── Specialization ─────────────────────────────────────────────────

  void toggleSpecialization(String spec, bool selected) {
    final updated = List<String>.from(state.filter.specializations);
    if (selected) {
      updated.add(spec);
    } else {
      updated.remove(spec);
    }
    final updatedFilter = state.filter.copyWith(specializations: updated);
    emit(state.copyWith(filter: updatedFilter));
  }

  // ── Experience ─────────────────────────────────────────────────────

  void toggleExperienceRange(String range, bool selected) {
    final updated = List<String>.from(state.filter.experienceRanges);
    if (selected) {
      updated.add(range);
    } else {
      updated.remove(range);
    }
    final updatedFilter = state.filter.copyWith(experienceRanges: updated);
    emit(state.copyWith(filter: updatedFilter));
  }

  // ── Availability ───────────────────────────────────────────────────

  void updateAvailableToday(bool value) {
    final updatedFilter = state.filter.copyWith(
      availableToday: value,
      availableThisWeek: value ? false : state.filter.availableThisWeek,
    );
    emit(state.copyWith(filter: updatedFilter));
  }

  void updateAvailableThisWeek(bool value) {
    final updatedFilter = state.filter.copyWith(
      availableThisWeek: value,
      availableToday: value ? false : state.filter.availableToday,
    );
    emit(state.copyWith(filter: updatedFilter));
  }

  // ── Gender ─────────────────────────────────────────────────────────

  void updateGender(String? gender, bool selected) {
    final updatedFilter = state.filter.copyWith(
      gender: selected ? gender : null,
      clearGender: !selected,
    );
    emit(state.copyWith(filter: updatedFilter));
  }

  void clearGender() {
    final updatedFilter = state.filter.copyWith(clearGender: true);
    emit(state.copyWith(filter: updatedFilter));
  }

  // ── Clear All ──────────────────────────────────────────────────────

  void clearAll() {
    emit(const DoctorFilterSheetState());
  }
}
