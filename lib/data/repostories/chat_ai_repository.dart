import 'dart:typed_data';
import 'package:idoc_user/data/models/medical_chat_message.dart';


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