import 'package:equatable/equatable.dart';

abstract class AppointmentsListEvent extends Equatable {
  const AppointmentsListEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserAppointmentsEvent extends AppointmentsListEvent {
  final String userId;

  const FetchUserAppointmentsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CancelAppointmentEvent extends AppointmentsListEvent {
  final String appointmentId;
  final String doctorId;
  final String slotId;
  final String userId;

  const CancelAppointmentEvent({
    required this.appointmentId,
    required this.doctorId,
    required this.slotId,
    required this.userId,
  });

  @override
  List<Object?> get props => [appointmentId, doctorId, slotId, userId];
}

class RefreshAppointmentsEvent extends AppointmentsListEvent {
  final String userId;

  const RefreshAppointmentsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}