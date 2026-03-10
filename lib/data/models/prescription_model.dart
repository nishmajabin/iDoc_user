import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionMedication {
  final String medication;
  final int dosage;
  final int duration;
  final String durationUnit;
  final String repeat;
  final String timeOfDay;
  final String beTaken;

  const PrescriptionMedication({
    required this.medication,
    required this.dosage,
    required this.duration,
    required this.durationUnit,
    required this.repeat,
    required this.timeOfDay,
    required this.beTaken,
  });

  factory PrescriptionMedication.fromMap(Map<String, dynamic> map) =>
      PrescriptionMedication(
        medication: map['medication'] as String? ?? '',
        dosage: (map['dosage'] as num?)?.toInt() ?? 1,
        duration: (map['duration'] as num?)?.toInt() ?? 1,
        durationUnit: map['durationUnit'] as String? ?? 'Day',
        repeat: map['repeat'] as String? ?? 'Everyday',
        timeOfDay: map['timeOfDay'] as String? ?? 'Morning',
        beTaken: map['beTaken'] as String? ?? 'After Food',
      );
}

class UserPrescriptionRecord {
  final String id;
  final String appointmentId;
  final String patientName;
  final String docNote;
  final DateTime timestamp;
  final List<PrescriptionMedication> medications;

  // Doctor info — pulled from appointment or passed in
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const UserPrescriptionRecord({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.docNote,
    required this.timestamp,
    required this.medications,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  });

  factory UserPrescriptionRecord.fromFirestore({
    required String docId,
    required String appointmentId,
    required Map<String, dynamic> data,
    String? doctorName,
    String? doctorSpecialist,
    String? doctorProfileImageUrl,
  }) {
    final rawList = data['prescriptions'] as List<dynamic>? ?? [];
    return UserPrescriptionRecord(
      id: docId,
      appointmentId: appointmentId,
      patientName: data['name'] as String? ?? '',
      docNote: data['docnote'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      medications: rawList
          .map((e) => PrescriptionMedication.fromMap(e as Map<String, dynamic>))
          .toList(),
      doctorName: doctorName,
      doctorSpecialist: doctorSpecialist,
      doctorProfileImageUrl: doctorProfileImageUrl,
    );
  }
}