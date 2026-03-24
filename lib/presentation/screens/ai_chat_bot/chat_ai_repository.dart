import 'dart:typed_data';

import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';

/// Abstract contract for the medical chatbot repository.
///
/// The implementation ([MedicalChatRepositoryImpl]) handles
/// fallback logic between providers transparently.
abstract class MedicalChatRepository {
  /// Send a text-only message to the AI medical chatbot.
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
  });

  /// Send a message with an image attachment for medical analysis.
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
  });
}