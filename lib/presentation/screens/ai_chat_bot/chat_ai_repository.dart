import 'dart:typed_data';

import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';

abstract class MedicalChatRepository {
  /// Send a text-only message to the Gemini medical chatbot.
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
  });

  /// Send a message with an image attachment for visual analysis.
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
  });
}