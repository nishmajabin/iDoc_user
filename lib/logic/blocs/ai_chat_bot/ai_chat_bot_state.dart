import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/medical_chat_message.dart';

abstract class MedicalChatState extends Equatable {
  final List<MedicalChatMessage> messages;
  final Uint8List? pendingImage;

  const MedicalChatState({
    required this.messages,
    this.pendingImage,
  });

  @override
  List<Object?> get props => [messages, pendingImage];
}

class MedicalChatInitial extends MedicalChatState {
  const MedicalChatInitial({
    super.messages = const [],
    super.pendingImage,
  });
}

/// AI is processing — show shimmer/loading indicator.
class MedicalChatLoading extends MedicalChatState {
  const MedicalChatLoading({
    required super.messages,
    super.pendingImage,
  });
}

/// AI responded successfully.
class MedicalChatLoaded extends MedicalChatState {
  const MedicalChatLoaded({
    required super.messages,
    super.pendingImage,
  });
}

/// API call failed — error bubble shown in chat.
class MedicalChatError extends MedicalChatState {
  final String errorMessage;

  const MedicalChatError({
    required super.messages,
    required this.errorMessage,
    super.pendingImage,
  });

  @override
  List<Object?> get props => [messages, errorMessage, pendingImage];
}