import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:idoc_user/core/handlers/send_message_use_case_handler.dart';
import 'package:idoc_user/data/repostories/chat_repository_impl.dart';
import 'package:idoc_user/data/services/ai_chat/groq_chat_service.dart';
import 'package:idoc_user/data/services/ai_chat/openrouter_chat_service.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/screen/medical_chat_ai_screen.dart';



class MedicalChatFactory {
  MedicalChatFactory._();

  static Widget create() {
    // ── Read API keys from .env (NEVER hardcode!) ────────────────────────
    final groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    final openRouterApiKey = dotenv.env['OPEN_ROUTER_API_KEY'] ?? '';

    assert(
      groqApiKey.isNotEmpty,
      'GROQ_API_KEY is not set in your .env file.\n'
      'Add: GROQ_API_KEY=gsk_...\n'
      'Get one from: https://console.groq.com',
    );

    assert(
      openRouterApiKey.isNotEmpty,
      'OPEN_ROUTER_API_KEY is not set in your .env file.\n'
      'Add: OPEN_ROUTER_API_KEY=sk-or-...\n'
      'Get one from: https://openrouter.ai/keys',
    );

    // ── Create services ─────────────────────────────────────────────────
    final groqService = GroqChatService(apiKey: groqApiKey);
    final openRouterService = OpenRouterChatService(apiKey: openRouterApiKey);

    // ── Repository with fallback: Groq → OpenRouter ─────────────────────
    final repository = MedicalChatRepositoryImpl(
      primary: groqService,
      fallback: openRouterService,
    );

    return BlocProvider(
      create: (_) => MedicalChatBloc(
        sendMessage: SendMedicalMessageUseCase(repository),
        sendImageMessage: SendMedicalImageMessageUseCase(repository),
      ),
      child: const MedicalChatScreen(),
    );
  }
}