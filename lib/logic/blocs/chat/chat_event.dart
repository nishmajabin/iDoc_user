
import 'package:equatable/equatable.dart';

abstract class UserChatEvent extends Equatable {
  const UserChatEvent();
  @override
  List<Object?> get props => [];
}

/// Fired when patient opens a chat from their appointment detail screen.
class InitializeUserChat extends UserChatEvent {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? doctorName;
  final String? patientName;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;

  const InitializeUserChat({
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.doctorName,
    this.patientName,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
  });

  @override
  List<Object?> get props => [doctorId, patientId, appointmentId];
}

class SendUserMessage extends UserChatEvent {
  final String messageText;
  const SendUserMessage(this.messageText);
  @override
  List<Object?> get props => [messageText];
}

class MarkUserMessagesRead extends UserChatEvent {
  const MarkUserMessagesRead();
}

class DisposeUserChat extends UserChatEvent {
  const DisposeUserChat();
}