import 'package:equatable/equatable.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class PatientDetailsSet extends AppointmentState {
  final String patientName;
  final String contactNumber;
  final String description;

  const PatientDetailsSet({
    required this.patientName,
    required this.contactNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [patientName, contactNumber, description];
}

class SlotsFetched extends AppointmentState {
  final List<Map<String, dynamic>> slots;
  final DateTime selectedDate;
  final String? patientName;
  final String? contactNumber;
  final String? description;
  final String? selectedSlotId;
  final String? selectedStartTime;
  final String? selectedEndTime;

  const SlotsFetched({
    required this.slots,
    required this.selectedDate,
    this.patientName,
    this.contactNumber,
    this.description,
    this.selectedSlotId,
    this.selectedStartTime,
    this.selectedEndTime,
  });

  SlotsFetched copyWith({
    List<Map<String, dynamic>>? slots,
    DateTime? selectedDate,
    String? patientName,
    String? contactNumber,
    String? description,
    String? selectedSlotId,
    String? selectedStartTime,
    String? selectedEndTime,
  }) {
    return SlotsFetched(
      slots: slots ?? this.slots,
      selectedDate: selectedDate ?? this.selectedDate,
      patientName: patientName ?? this.patientName,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      selectedSlotId: selectedSlotId,
      selectedStartTime: selectedStartTime,
      selectedEndTime: selectedEndTime,
    );
  }

  @override
  List<Object?> get props => [
        slots,
        selectedDate,
        patientName,
        contactNumber,
        description,
        selectedSlotId,
        selectedStartTime,
        selectedEndTime,
      ];
}

class AppointmentBooked extends AppointmentState {
  final String appointmentId;
  final String doctorName;
  final String startTime;
  final String endTime;
  final DateTime appointmentDate;

  const AppointmentBooked({
    required this.appointmentId,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.appointmentDate,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        doctorName,
        startTime,
        endTime,
        appointmentDate,
      ];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentsLoaded extends AppointmentState {
  final List<dynamic> appointments; // Will be AppointmentModel

  const AppointmentsLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}