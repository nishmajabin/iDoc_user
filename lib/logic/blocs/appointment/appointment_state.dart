import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

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

/// Emitted while [FetchPatientNameEvent] is in-flight, so the UI can show
/// a skeleton / shimmer only on the name field, not the whole screen.
class PatientNameLoading extends AppointmentState {
  const PatientNameLoading();
}

/// Emitted once the patient name has been successfully fetched from Firestore.
///
/// [patientName] is null when the user document exists but has no name field,
/// or when the fetch returned an error — the UI should fall back to the
/// editable text field in that case (see [PatientDetailsScreen]).
class PatientNameFetched extends AppointmentState {
  final String? patientName;

  const PatientNameFetched({this.patientName});

  @override
  List<Object?> get props => [patientName];
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
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}