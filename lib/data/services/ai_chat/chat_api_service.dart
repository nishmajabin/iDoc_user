import 'dart:typed_data';
import 'package:idoc_user/data/models/medical_chat_message.dart';

abstract class ChatApiService {
  /// Human-readable name used for logging, e.g. "Groq" or "OpenRouter".
  String get providerName;

  /// Send a text-only prompt and return the AI response.
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  });

  /// Send a prompt with an image attachment (vision-capable models only).
  /// Falls back to text-only if the underlying model doesn't support images.
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  });

  /// Release HTTP resources.
  void dispose();
}
