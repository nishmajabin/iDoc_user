import 'dart:typed_data';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';


class MedicalChatMessageModel extends MedicalChatMessage {
  const MedicalChatMessageModel({
    required super.id,
    super.text,
    required super.role,
    required super.timestamp,
    super.isError,
    super.imageBytes,
  });

  /// Parse a successful Gemini REST response body.
  ///
  /// Gemini response shape:
  /// {
  ///   "candidates": [{
  ///     "content": {
  ///       "parts": [{ "text": "..." }],
  ///       "role": "model"
  ///     }
  ///   }]
  /// }
  factory MedicalChatMessageModel.fromGeminiResponse(
    Map<String, dynamic> json,
    String messageId,
  ) {
    String extractedText = 'No response received.';

    try {
      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          extractedText = parts[0]['text'] as String? ?? extractedText;
        }
      }
      // Fallback: some older model versions use 'output' directly
      if (extractedText == 'No response received.' &&
          json['candidates']?[0]?['output'] != null) {
        extractedText = json['candidates'][0]['output'].toString();
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