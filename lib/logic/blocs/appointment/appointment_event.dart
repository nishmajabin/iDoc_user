import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class SetPatientDetailsEvent extends AppointmentEvent {
  final String patientName;
  final String contactNumber;
  final String description;

  const SetPatientDetailsEvent({
    required this.patientName,
    required this.contactNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [patientName, contactNumber, description];
}

class FetchAvailableSlotsEvent extends AppointmentEvent {
  final String doctorId;
  final DateTime date;

  const FetchAvailableSlotsEvent({
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object?> get props => [doctorId, date];
}

class FetchAvailableSlotsRangeEvent extends AppointmentEvent {
  final String doctorId;
  final DateTime startDate;
  final DateTime endDate;

  const FetchAvailableSlotsRangeEvent({
    required this.doctorId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [doctorId, startDate, endDate];
}

class FetchAllAvailableSlotsEvent extends AppointmentEvent {
  final String doctorId;

  const FetchAllAvailableSlotsEvent({
    required this.doctorId,
  });

  @override
  List<Object?> get props => [doctorId];
}

class SelectDateEvent extends AppointmentEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectSlotEvent extends AppointmentEvent {
  final String slotId;
  final String startTime;
  final String endTime;

  const SelectSlotEvent({
    required this.slotId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [slotId, startTime, endTime];
}

class BookAppointmentEvent extends AppointmentEvent {
  final String doctorId;
  final String userId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const BookAppointmentEvent({
    required this.doctorId,
    required this.userId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  });

  @override
  List<Object?> get props => [
        doctorId,
        userId,
        doctorName,
        doctorSpecialist,
        doctorProfileImageUrl,
      ];
}

class ResetBookingEvent extends AppointmentEvent {
  const ResetBookingEvent();
}

class FetchUserAppointmentsEvent extends AppointmentEvent {
  final String userId;

  const FetchUserAppointmentsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CancelAppointmentEvent extends AppointmentEvent {
  final String appointmentId;
  final String doctorId;
  final String slotId;

  const CancelAppointmentEvent({
    required this.appointmentId,
    required this.doctorId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [appointmentId, doctorId, slotId];
}