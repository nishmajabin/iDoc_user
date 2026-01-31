import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

abstract class AppointmentsListState extends Equatable {
  const AppointmentsListState();

  @override
  List<Object?> get props => [];
}

class AppointmentsListInitial extends AppointmentsListState {
  const AppointmentsListInitial();
}

class AppointmentsListLoading extends AppointmentsListState {
  const AppointmentsListLoading();
}

class AppointmentsListLoaded extends AppointmentsListState {
  final List<AppointmentModel> upcomingAppointments;
  final List<AppointmentModel> pastAppointments;

  const AppointmentsListLoaded({
    required this.upcomingAppointments,
    required this.pastAppointments,
  });

  @override
  List<Object?> get props => [upcomingAppointments, pastAppointments];
}

class AppointmentCancelling extends AppointmentsListState {
  final String appointmentId;

  const AppointmentCancelling(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class AppointmentCancelled extends AppointmentsListState {
  final String message;

  const AppointmentCancelled(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentsListError extends AppointmentsListState {
  final String message;

  const AppointmentsListError(this.message);

  @override
  List<Object?> get props => [message];
}