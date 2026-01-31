import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? appointmentId;
  final String doctorId;
  final String userId;
  final String slotId;
  final String patientName;
  final String contactNumber;
  final String description; // Added description field
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status; // pending, confirmed, cancelled, completed
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Doctor details (denormalized for easier access)
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  AppointmentModel({
    this.appointmentId,
    required this.doctorId,
    required this.userId,
    required this.slotId,
    required this.patientName,
    required this.contactNumber,
    required this.description,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
    DateTime? createdAt,
    this.updatedAt,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'slotId': slotId,
      'patientName': patientName,
      'contactNumber': contactNumber,
      'description': description,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'doctorName': doctorName,
      'doctorSpecialist': doctorSpecialist,
      'doctorProfileImageUrl': doctorProfileImageUrl,
    };
  }

  // Create from Firestore document
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppointmentModel(
      appointmentId: doc.id,
      doctorId: data['doctorId'] ?? '',
      userId: data['userId'] ?? '',
      slotId: data['slotId'] ?? '',
      patientName: data['patientName'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      doctorName: data['doctorName'],
      doctorSpecialist: data['doctorSpecialist'],
      doctorProfileImageUrl: data['doctorProfileImageUrl'],
    );
  }

  // Copy with
  AppointmentModel copyWith({
    String? appointmentId,
    String? doctorId,
    String? userId,
    String? slotId,
    String? patientName,
    String? contactNumber,
    String? description,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? doctorName,
    String? doctorSpecialist,
    String? doctorProfileImageUrl,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      slotId: slotId ?? this.slotId,
      patientName: patientName ?? this.patientName,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialist: doctorSpecialist ?? this.doctorSpecialist,
      doctorProfileImageUrl: doctorProfileImageUrl ?? this.doctorProfileImageUrl,
    );
  }
}