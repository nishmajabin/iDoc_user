import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_bloc.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_ai_repository.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_repository_impl.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/gemini_chat_service.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/medical_chat_screen.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/send_message_usecase.dart';

/// Single entry point — call this to navigate to the medical chatbot.
///
/// Usage (from anywhere in your app):
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => MedicalChatFactory.create()),
/// );
/// ```
///
/// Make sure dotenv is loaded in main() before calling this:
/// ```dart
/// await dotenv.load(fileName: '.env');
/// ```
class MedicalChatFactory {
  MedicalChatFactory._();

  static Widget create() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    assert(
      apiKey.isNotEmpty,
      'GEMINI_API_KEY is not set in your .env file.\n'
      'Add: GEMINI_API_KEY=AIza...\n'
      'See: https://aistudio.google.com/apikey',
    );

    final service = MedicalGeminiApiService(apiKey: apiKey);
    final MedicalChatRepository repository =
        MedicalChatRepositoryImpl(service);

    return BlocProvider(
      create: (_) => MedicalChatBloc(
        sendMessage: SendMedicalMessageUseCase(repository),
        sendImageMessage: SendMedicalImageMessageUseCase(repository),
      ),
      child: const MedicalChatScreen(),
    );
  }
}