import 'package:idoc_user/data/models/medical_chat_message.dart';

class MedicalChatMessageModel extends MedicalChatMessage {
  const MedicalChatMessageModel({
    required super.id,
    super.text,
    required super.role,
    required super.timestamp,
    super.isError,
    super.imageBytes,
  });

  factory MedicalChatMessageModel.fromChatCompletion(
    Map<String, dynamic> json,
    String messageId,
  ) {
    String extractedText = 'No response received.';

    try {
      final choices = json['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        extractedText = message?['content'] as String? ?? extractedText;
      }
    } catch (_) {}

    return MedicalChatMessageModel(
      id: messageId,
      text: extractedText,
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  factory MedicalChatMessageModel.errorMessage({
    required String messageId,
    required String error,
  }) {
    return MedicalChatMessageModel(
      id: messageId,
      text: error,
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
      isError: true,
    );
  }

  factory MedicalChatMessageModel.fromEntity(MedicalChatMessage entity) {
    return MedicalChatMessageModel(
      id: entity.id,
      text: entity.text,
      role: entity.role,
      timestamp: entity.timestamp,
      isError: entity.isError,
      imageBytes: entity.imageBytes,
    );
  }
}