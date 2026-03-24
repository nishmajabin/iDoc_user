import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoomModel extends Equatable {
  final String chatRoomId;
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCountDoctor;
  final int unreadCountPatient;
  final String? doctorName;
  final String? patientName;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;
  final DateTime createdAt;

  const ChatRoomModel({
    required this.chatRoomId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCountDoctor = 0,
    this.unreadCountPatient = 0,
    this.doctorName,
    this.patientName,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
    required this.createdAt,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      chatRoomId: doc.id,
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      appointmentId: data['appointmentId'] as String? ?? '',
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      unreadCountDoctor: data['unreadCountDoctor'] as int? ?? 0,
      unreadCountPatient: data['unreadCountPatient'] as int? ?? 0,
      doctorName: data['doctorName'] as String?,
      patientName: data['patientName'] as String?,
      doctorProfileImageUrl: data['doctorProfileImageUrl'] as String?,
      patientProfileImageUrl: data['patientProfileImageUrl'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        chatRoomId,
        doctorId,
        patientId,
        appointmentId,
        lastMessage,
        lastMessageTime,
        unreadCountDoctor,
        unreadCountPatient,
      ];
}