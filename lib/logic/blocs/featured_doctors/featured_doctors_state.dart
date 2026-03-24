import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/doctor_model.dart';

abstract class FeaturedDoctorsState extends Equatable {
  const FeaturedDoctorsState();

  @override
  List<Object?> get props => [];
}

class FeaturedDoctorsInitial extends FeaturedDoctorsState {}

class FeaturedDoctorsLoading extends FeaturedDoctorsState {}

class FeaturedDoctorsLoaded extends FeaturedDoctorsState {
  final List<DoctorModel> doctors;

  const FeaturedDoctorsLoaded({required this.doctors});

  @override
  List<Object?> get props => [doctors];
}

class FeaturedDoctorsEmpty extends FeaturedDoctorsState {}

class FeaturedDoctorsError extends FeaturedDoctorsState {
  final String message;

  const FeaturedDoctorsError(this.message);

  @override
  List<Object?> get props => [message];
}
