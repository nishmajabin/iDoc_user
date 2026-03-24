import 'dart:typed_data';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';

/// Data model extension of [MedicalChatMessage].
///
/// Previously parsed Gemini-specific responses. Now the parsing is done
/// inside each [ChatApiService] implementation (Groq, OpenRouter, etc.)
/// since they all use the same OpenAI-compatible response format.
///
/// This model is retained for backward compatibility and utility helpers.
class MedicalChatMessageModel extends MedicalChatMessage {
  const MedicalChatMessageModel({
    required super.id,
    super.text,
    required super.role,
    required super.timestamp,
    super.isError,
    super.imageBytes,
  });

  /// Parse an OpenAI-compatible chat completion response.
  ///
  /// Response shape (Groq / OpenRouter):
  /// {
  ///   "choices": [{
  ///     "message": {
  ///       "role": "assistant",
  ///       "content": "..."
  ///     }
  ///   }]
  /// }
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