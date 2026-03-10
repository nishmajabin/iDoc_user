// lib/data/models/doctor_filter_model.dart
import 'package:equatable/equatable.dart';

class DoctorFilter extends Equatable {
  final double? minFee;
  final double? maxFee;
  final double? minRating;
  final List<String> specializations;
  final List<String> experienceRanges;
  final bool availableToday;
  final bool availableThisWeek;
  final String? gender;

  const DoctorFilter({
    this.minFee,
    this.maxFee,
    this.minRating,
    this.specializations = const [],
    this.experienceRanges = const [],
    this.availableToday = false,
    this.availableThisWeek = false,
    this.gender,
  });

  bool get hasActiveFilters {
    // Check if fee range is not default
    final hasCustomFee = (minFee != null && minFee != 0) || 
                        (maxFee != null && maxFee != 5000);
    
    return hasCustomFee ||
        minRating != null ||
        specializations.isNotEmpty ||
        experienceRanges.isNotEmpty ||
        availableToday ||
        availableThisWeek ||
        gender != null;
  }

  int get activeFilterCount {
    int count = 0;
    
    // Count fee filter (only if not default range)
    if ((minFee != null && minFee != 0) || (maxFee != null && maxFee != 5000)) {
      count++;
    }
    
    if (minRating != null) count++;
    count += specializations.length;
    count += experienceRanges.length;
    if (availableToday) count++;
    if (availableThisWeek) count++;
    if (gender != null) count++;
    
    return count;
  }

  DoctorFilter copyWith({
    double? minFee,
    double? maxFee,
    double? minRating,
    List<String>? specializations,
    List<String>? experienceRanges,
    bool? availableToday,
    bool? availableThisWeek,
    String? gender,
    bool clearGender = false,
  }) {
    return DoctorFilter(
      minFee: minFee ?? this.minFee,
      maxFee: maxFee ?? this.maxFee,
      minRating: minRating ?? this.minRating,
      specializations: specializations ?? this.specializations,
      experienceRanges: experienceRanges ?? this.experienceRanges,
      availableToday: availableToday ?? this.availableToday,
      availableThisWeek: availableThisWeek ?? this.availableThisWeek,
      gender: clearGender ? null : (gender ?? this.gender),
    );
  }

  @override
  List<Object?> get props => [
        minFee,
        maxFee,
        minRating,
        specializations,
        experienceRanges,
        availableToday,
        availableThisWeek,
        gender,
      ];

  @override
  String toString() {
    return 'DoctorFilter(minFee: $minFee, maxFee: $maxFee, minRating: $minRating, '
        'specializations: $specializations, experienceRanges: $experienceRanges, '
        'availableToday: $availableToday, availableThisWeek: $availableThisWeek, gender: $gender)';
  }
}