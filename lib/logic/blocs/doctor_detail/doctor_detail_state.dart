import 'package:idoc_user/data/models/doctor_model.dart';

abstract class DoctorDetailState {}

class DoctorDetailInitial extends DoctorDetailState {}

class DoctorDetailLoading extends DoctorDetailState {}

class DoctorDetailLoaded extends DoctorDetailState {
  final DoctorModel doctor;
  DoctorDetailLoaded(this.doctor);
}

class DoctorDetailError extends DoctorDetailState {
  final String message;
  DoctorDetailError(this.message);
}