import 'dart:typed_data';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_ai_repository.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';

class SendMedicalMessageUseCase {
  final MedicalChatRepository _repository;

  const SendMedicalMessageUseCase(this._repository);

  Future<MedicalChatMessage> call({
    required String prompt,
    required List<MedicalChatMessage> history,
  }) {
    return _repository.sendMessage(prompt: prompt, history: history);
  }
}

class SendMedicalImageMessageUseCase {
  final MedicalChatRepository _repository;

  const SendMedicalImageMessageUseCase(this._repository);

  Future<MedicalChatMessage> call({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
  }) {
    return _repository.sendImageMessage(
      imageBytes: imageBytes,
      prompt: prompt,
      history: history,
    );
  }
}