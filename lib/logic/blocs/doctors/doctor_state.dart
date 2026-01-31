import 'package:idoc_user/data/models/doctor_model.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> allDoctors;
  final String searchQuery;
  final String? currentCategory;
  
  DoctorLoaded({
    required this.doctors,
    required this.allDoctors,
    this.searchQuery = '',
    this.currentCategory,
  });

  DoctorLoaded copyWith({
    List<DoctorModel>? doctors,
    List<DoctorModel>? allDoctors,
    String? searchQuery,
    String? currentCategory,
  }) {
    return DoctorLoaded(
      doctors: doctors ?? this.doctors,
      allDoctors: allDoctors ?? this.allDoctors,
      searchQuery: searchQuery ?? this.searchQuery,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

class DoctorError extends DoctorState {
  final String message;
  final String? currentCategory;
  
  DoctorError(this.message, {this.currentCategory});
}
