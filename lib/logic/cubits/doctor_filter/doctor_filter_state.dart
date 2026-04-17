import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';

class DoctorFilterSheetState extends Equatable {
  final DoctorFilter filter;
  final RangeValues feeRange;
  final double? selectedRating;

  const DoctorFilterSheetState({
    this.filter = const DoctorFilter(),
    this.feeRange = const RangeValues(0, 5000),
    this.selectedRating,
  });

  DoctorFilterSheetState copyWith({
    DoctorFilter? filter,
    RangeValues? feeRange,
    double? selectedRating,
    bool clearRating = false,
  }) {
    return DoctorFilterSheetState(
      filter: filter ?? this.filter,
      feeRange: feeRange ?? this.feeRange,
      selectedRating: clearRating ? null : (selectedRating ?? this.selectedRating),
    );
  }

  @override
  List<Object?> get props => [filter, feeRange, selectedRating];
}
