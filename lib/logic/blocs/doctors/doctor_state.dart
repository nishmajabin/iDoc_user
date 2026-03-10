// import 'package:idoc_user/data/models/doctor_model.dart';

// abstract class DoctorState {}

// class DoctorInitial extends DoctorState {}

// class DoctorLoading extends DoctorState {}

// class DoctorLoaded extends DoctorState {
//   final List<DoctorModel> doctors;
//   final List<DoctorModel> allDoctors;
//   final String searchQuery;
//   final String? currentCategory;
  
//   DoctorLoaded({
//     required this.doctors,
//     required this.allDoctors,
//     this.searchQuery = '',
//     this.currentCategory,
//   });

//   DoctorLoaded copyWith({
//     List<DoctorModel>? doctors,
//     List<DoctorModel>? allDoctors,
//     String? searchQuery,
//     String? currentCategory,
//   }) {
//     return DoctorLoaded(
//       doctors: doctors ?? this.doctors,
//       allDoctors: allDoctors ?? this.allDoctors,
//       searchQuery: searchQuery ?? this.searchQuery,
//       currentCategory: currentCategory ?? this.currentCategory,
//     );
//   }
// }

// class DoctorError extends DoctorState {
//   final String message;
//   final String? currentCategory;
  
//   DoctorError(this.message, {this.currentCategory});
// }

// lib/logic/blocs/doctors/doctor_state.dart
// lib/logic/blocs/doctors/doctor_state.dart
import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/data/models/doctor_model.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> allDoctors;
  final String? currentCategory;
  final String searchQuery;
  final DoctorFilter filter;

  const DoctorLoaded({
    required this.doctors,
    required this.allDoctors,
    this.currentCategory,
    this.searchQuery = '',
    this.filter = const DoctorFilter(),
  });

  DoctorLoaded copyWith({
    List<DoctorModel>? doctors,
    List<DoctorModel>? allDoctors,
    String? currentCategory,
    String? searchQuery,
    DoctorFilter? filter,
  }) {
    return DoctorLoaded(
      doctors: doctors ?? this.doctors,
      allDoctors: allDoctors ?? this.allDoctors,
      currentCategory: currentCategory ?? this.currentCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        doctors,
        allDoctors,
        currentCategory,
        searchQuery,
        filter,
      ];
}

class DoctorError extends DoctorState {
  final String message;
  final String? currentCategory;

  const DoctorError(this.message, {this.currentCategory});

  @override
  List<Object?> get props => [message, currentCategory];
}