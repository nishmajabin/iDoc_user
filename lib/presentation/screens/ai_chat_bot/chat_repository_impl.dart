import 'dart:typed_data';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_ai_repository.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/gemini_chat_service.dart';
import 'package:uuid/uuid.dart';

class MedicalChatRepositoryImpl implements MedicalChatRepository {
  final MedicalGeminiApiService _apiService;
  static const _uuid = Uuid();

  const MedicalChatRepositoryImpl(this._apiService);

  @override
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
  }) {
    return _apiService.sendMessage(
      prompt: prompt,
      history: history,
      responseMessageId: _uuid.v4(),
    );
  }

  @override
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
  }) {
    return _apiService.sendImageMessage(
      imageBytes: imageBytes,
      prompt: prompt,
      history: history,
      responseMessageId: _uuid.v4(),
    );
  }
}