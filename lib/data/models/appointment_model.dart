// import 'package:cloud_firestore/cloud_firestore.dart';

// class AppointmentModel {
//   final String? appointmentId;
//   final String doctorId;
//   final String userId;
//   final String slotId;
//   final String patientName;
//   final String contactNumber;
//   final String description;
//   final DateTime appointmentDate;
//   final String startTime;
//   final String endTime;
//   final String status;
//   final String? doctorName;
//   final String? doctorSpecialist;
//   final String? doctorProfileImageUrl;
//   final String? profileImageUrl; // ← User's profile image

//   AppointmentModel({
//     this.appointmentId,
//     required this.doctorId,
//     required this.userId,
//     required this.slotId,
//     required this.patientName,
//     required this.contactNumber,
//     required this.description,
//     required this.appointmentDate,
//     required this.startTime,
//     required this.endTime,
//     required this.status,
//     this.doctorName,
//     this.doctorSpecialist,
//     this.doctorProfileImageUrl,
//     this.profileImageUrl, // ← Add to constructor
//   });

//   // Convert to Firestore map
//   Map<String, dynamic> toFirestore() {
//     return {
//       if (appointmentId != null) 'appointmentId': appointmentId,
//       'doctorId': doctorId,
//       'userId': userId,
//       'slotId': slotId,
//       'patientName': patientName,
//       'contactNumber': contactNumber,
//       'description': description,
//       'appointmentDate': Timestamp.fromDate(appointmentDate),
//       'startTime': startTime,
//       'endTime': endTime,
//       'status': status,
//       if (doctorName != null) 'doctorName': doctorName,
//       if (doctorSpecialist != null) 'doctorSpecialist': doctorSpecialist,
//       if (doctorProfileImageUrl != null) 'doctorProfileImageUrl': doctorProfileImageUrl,
//       if (profileImageUrl != null) 'profileImageUrl': profileImageUrl, // ← Add to Firestore
//       'createdAt': FieldValue.serverTimestamp(),
//     };
//   }

//   // Create from Firestore document
//   factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
    
//     return AppointmentModel(
//       appointmentId: doc.id,
//       doctorId: data['doctorId'] as String,
//       userId: data['userId'] as String,
//       slotId: data['slotId'] as String,
//       patientName: data['patientName'] as String,
//       contactNumber: data['contactNumber'] as String,
//       description: data['description'] as String,
//       appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
//       startTime: data['startTime'] as String,
//       endTime: data['endTime'] as String,
//       status: data['status'] as String,
//       doctorName: data['doctorName'] as String?,
//       doctorSpecialist: data['doctorSpecialist'] as String?,
//       doctorProfileImageUrl: data['doctorProfileImageUrl'] as String?,
//       profileImageUrl: data['profileImageUrl'] as String?, // ← Read from Firestore
//     );
//   }

//   // Copy with method - ✨ FIXED: Added profileImageUrl parameter
//   AppointmentModel copyWith({
//     String? appointmentId,
//     String? doctorId,
//     String? userId,
//     String? slotId,
//     String? patientName,
//     String? contactNumber,
//     String? description,
//     DateTime? appointmentDate,
//     String? startTime,
//     String? endTime,
//     String? status,
//     String? doctorName,
//     String? doctorSpecialist,
//     String? doctorProfileImageUrl,
//     String? profileImageUrl, // ← ADD THIS PARAMETER
//   }) {
//     return AppointmentModel(
//       appointmentId: appointmentId ?? this.appointmentId,
//       doctorId: doctorId ?? this.doctorId,
//       userId: userId ?? this.userId,
//       slotId: slotId ?? this.slotId,
//       patientName: patientName ?? this.patientName,
//       contactNumber: contactNumber ?? this.contactNumber,
//       description: description ?? this.description,
//       appointmentDate: appointmentDate ?? this.appointmentDate,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       status: status ?? this.status,
//       doctorName: doctorName ?? this.doctorName,
//       doctorSpecialist: doctorSpecialist ?? this.doctorSpecialist,
//       doctorProfileImageUrl: doctorProfileImageUrl ?? this.doctorProfileImageUrl,
//       profileImageUrl: profileImageUrl ?? this.profileImageUrl, // ← USE THE PARAMETER
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? appointmentId;
  final String doctorId;
  final String userId;
  final String slotId;
  final String patientName;
  final String contactNumber;
  final String description;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ✨ NEW: Payment-related fields
  final String? paymentId;
  final String? orderId;
  final double? consultationFee;
  final String? paymentStatus; // 'pending', 'paid', 'failed', 'refunded'

  const AppointmentModel({
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
    required this.status,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.paymentId,
    this.orderId,
    this.consultationFee,
    this.paymentStatus,
  });

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
    String? doctorName,
    String? doctorSpecialist,
    String? doctorProfileImageUrl,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    String? orderId,
    double? consultationFee,
    String? paymentStatus,
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
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialist: doctorSpecialist ?? this.doctorSpecialist,
      doctorProfileImageUrl: doctorProfileImageUrl ?? this.doctorProfileImageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      consultationFee: consultationFee ?? this.consultationFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (appointmentId != null) 'appointmentId': appointmentId,
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
      if (doctorName != null) 'doctorName': doctorName,
      if (doctorSpecialist != null) 'doctorSpecialist': doctorSpecialist,
      if (doctorProfileImageUrl != null) 'doctorProfileImageUrl': doctorProfileImageUrl,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      if (paymentId != null) 'paymentId': paymentId,
      if (orderId != null) 'orderId': orderId,
      if (consultationFee != null) 'consultationFee': consultationFee,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
    };
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppointmentModel(
      appointmentId: data['appointmentId'] as String? ?? doc.id,
      doctorId: data['doctorId'] as String,
      userId: data['userId'] as String,
      slotId: data['slotId'] as String,
      patientName: data['patientName'] as String,
      contactNumber: data['contactNumber'] as String,
      description: data['description'] as String,
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      startTime: data['startTime'] as String,
      endTime: data['endTime'] as String,
      status: data['status'] as String,
      doctorName: data['doctorName'] as String?,
      doctorSpecialist: data['doctorSpecialist'] as String?,
      doctorProfileImageUrl: data['doctorProfileImageUrl'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      paymentId: data['paymentId'] as String?,
      orderId: data['orderId'] as String?,
      consultationFee: data['consultationFee'] != null ? (data['consultationFee'] as num).toDouble() : null,
      paymentStatus: data['paymentStatus'] as String?,
    );
  }
}