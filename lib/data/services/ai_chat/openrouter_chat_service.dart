import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:idoc_user/data/models/medical_chat_message.dart';
import 'package:idoc_user/data/services/ai_chat/chat_api_service.dart';
import 'package:idoc_user/data/services/ai_chat/medical_api_exception.dart';
import 'package:idoc_user/data/services/ai_chat/medical_system_prompt.dart';

/// OpenRouter API service — **fallback** AI provider.
///
/// Uses the OpenAI-compatible `/v1/chat/completions` endpoint.
/// Model: `mistralai/mistral-small-3.1-24b-instruct:free` (free tier, reliable).
class OpenRouterChatService implements ChatApiService {
  final String _apiKey;
  final http.Client _client;

  static const String _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'mistralai/mistral-small-3.1-24b-instruct:free';
  static const Duration _timeout = Duration(seconds: 60);

  @override
  String get providerName => 'OpenRouter';

  OpenRouterChatService({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  // ── Public API ──────────────────────────────────────────────────────────

  @override
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  }) async {
    _validateApiKey();
    final messages = _buildMessages(prompt: prompt, history: history);
    final responseBody = await _post(messages);
    return _parseResponse(responseBody, responseMessageId);
  }

  @override
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  }) async {
    // mistral-7b-instruct doesn't support vision — send as text-only.
    final textPrompt = (prompt != null && prompt.isNotEmpty)
        ? '$prompt\n\n(Note: An image was attached but this model does not support image analysis. Please describe the image verbally.)'
        : 'The user attached a medical image. Please ask the user to describe the image verbally, as image analysis is not available with this model.';

    return sendMessage(
      prompt: textPrompt,
      history: history,
      responseMessageId: responseMessageId,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw const MedicalApiException(
        'OpenRouter API key is missing. Add OPEN_ROUTER_API_KEY to your .env file.',
      );
    }
  }

  /// Build the OpenAI-compatible messages array.
  /// Only sends the **last 6 conversational turns** (to keep requests small).
  List<Map<String, dynamic>> _buildMessages({
    required String prompt,
    required List<MedicalChatMessage> history,
  }) {
    final messages = <Map<String, dynamic>>[];

    // System prompt
    messages.add({
      'role': 'system',
      'content': kMedicalSystemPrompt,
    });

    // Last N turns of history (skip errors, image-only msgs)
    final relevantHistory = history
        .where((m) => !m.isError && m.hasText && !m.hasImage)
        .toList();

    // Keep only the most recent 6 messages (3 pairs of user/assistant)
    final trimmed = relevantHistory.length > 6
        ? relevantHistory.sublist(relevantHistory.length - 6)
        : relevantHistory;

    for (final m in trimmed) {
      messages.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text ?? '',
      });
    }

    // Current prompt
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    return messages;
  }

  /// POST to the OpenRouter endpoint.
  Future<Map<String, dynamic>> _post(
      List<Map<String, dynamic>> messages) async {
    final url = Uri.parse(_endpoint);
    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'temperature': 0.4,
      'max_tokens': 1024,
      'top_p': 0.8,
    });

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'HTTP-Referer': 'https://idoc-app.com',
              'X-Title': 'iDoc Medical AI',
            },
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      debugPrint(
          '[$providerName] HTTP ${response.statusCode}: ${response.body}');
      throw MedicalApiException(
        _mapHttpError(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const MedicalApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const MedicalApiException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw MedicalApiException('Network error: ${e.message}');
    }
  }

  /// Parse the OpenAI-compatible response.
  MedicalChatMessage _parseResponse(
    Map<String, dynamic> json,
    String messageId,
  ) {
    String text = 'No response received.';
    try {
      final choices = json['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        text = message?['content'] as String? ?? text;
      }
    } catch (_) {}

    return MedicalChatMessage(
      id: messageId,
      text: text,
      role: ChatRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  String _mapHttpError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try rephrasing your question.';
      case 401:
      case 403:
        return 'Invalid or unauthorized API key. Please verify your OpenRouter API key.';
      case 429:
        return 'Rate limit reached on backup provider. Please wait and try again.';
      case 500:
      case 502:
      case 503:
        return 'Backup AI service is temporarily unavailable.';
      default:
        return 'Something went wrong (code $statusCode). Please try again.';
    }
  }

  @override
  void dispose() => _client.close();
}
