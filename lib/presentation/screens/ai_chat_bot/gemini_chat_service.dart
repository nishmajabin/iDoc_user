import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:idoc_user/core/constants/gemini_endpoints.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message_model.dart';


/// System prompt that constrains Gemini to medical topics only.
const String _kMedicalSystemPrompt =
    'You are a professional medical AI assistant integrated into a doctor '
    'consultation app. Your role is to: '
    '1) Answer health and medical questions concisely and accurately. '
    '2) Analyze medical images when provided and describe relevant findings. '
    '3) Remind users to consult a qualified doctor for diagnosis or treatment. '
    '4) Politely decline non-medical questions. '
    'Use plain text only — no markdown, bullet points, or symbols. '
    'Always recommend professional consultation for serious symptoms.';

/// Low-level HTTP service that talks directly to the Gemini REST API.
///
/// WHY HTTP INSTEAD OF google_generative_ai PACKAGE?
/// Using http gives full control over the request shape, headers,
/// error handling, and response parsing — which is better for
/// production apps where you need predictable behavior.
class MedicalGeminiApiService {
  final String _apiKey;
  final http.Client _client;

  MedicalGeminiApiService({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  // ── Text-only message ────────────────────────────────────────────────────

  Future<MedicalChatMessageModel> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  }) async {
    _validateApiKey();

    final body = _buildRequestBody(
      currentParts: [
        {'text': prompt}
      ],
      history: history,
    );

    final response = await _post(body);
    return _parseResponse(response, responseMessageId);
  }

  // ── Image + optional text message ────────────────────────────────────────

  Future<MedicalChatMessageModel> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
    required String responseMessageId,
  }) async {
    _validateApiKey();

    final base64Image = base64Encode(imageBytes);
    final parts = <Map<String, dynamic>>[
      if (prompt != null && prompt.isNotEmpty) {'text': prompt},
      {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        }
      },
    ];

    // If no prompt provided, add a default medical analysis request
    if (prompt == null || prompt.isEmpty) {
      parts.insert(0, {
        'text': 'Please analyze this medical image and describe any '
            'relevant health observations.'
      });
    }

    final body = _buildRequestBody(
      currentParts: parts,
      history: history,
    );

    final response = await _post(body);
    return _parseResponse(response, responseMessageId);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _validateApiKey() {
    if (_apiKey.isEmpty) {
      throw MedicalApiException(
        'Gemini API key is missing. '
        'Add GEMINI_API_KEY to your .env file.',
      );
    }
  }

  /// Builds the Gemini REST request body.
  ///
  /// Request shape:
  /// {
  ///   "system_instruction": { "parts": [{"text": "..."}] },
  ///   "contents": [
  ///     {"role": "user",  "parts": [{"text": "..."}]},   // history
  ///     {"role": "model", "parts": [{"text": "..."}]},   // history
  ///     {"role": "user",  "parts": [...]}                // current turn
  ///   ],
  ///   "generationConfig": { "temperature": 0.4 }
  /// }
  Map<String, dynamic> _buildRequestBody({
    required List<Map<String, dynamic>> currentParts,
    required List<MedicalChatMessage> history,
  }) {
    // Convert history to Gemini's content format
    // Skip error messages and image-bearing history items
    final historyContents = history
        .where((m) => !m.isError && m.hasText && !m.hasImage)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'parts': [
                {'text': m.text}
              ],
            })
        .toList();

    return {
      'system_instruction': {
        'parts': [
          {'text': _kMedicalSystemPrompt}
        ],
      },
      'contents': [
        ...historyContents,
        {
          'role': 'user',
          'parts': currentParts,
        },
      ],
      'generationConfig': {
        'temperature': 0.4,       // Lower = more factual/medical
        'maxOutputTokens': 1024,
        'topP': 0.8,
      },
    };
  }

  Future<http.Response> _post(Map<String, dynamic> body) async {
    final url = Uri.parse(GeminiEndpoints.withKey(_apiKey));

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } on SocketException {
      throw MedicalApiException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException catch (e) {
      throw MedicalApiException('Network error: ${e.message}');
    }
  }

  MedicalChatMessageModel _parseResponse(
    http.Response response,
    String messageId,
  ) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MedicalChatMessageModel.fromGeminiResponse(data, messageId);
    }

    // Map HTTP status codes to friendly messages
    final errorBody = response.body;
    final friendlyError = _mapHttpError(response.statusCode, errorBody);
    throw MedicalApiException(friendlyError);
  }

  String _mapHttpError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try rephrasing your question.';
      case 401:
      case 403:
        return 'Invalid API key. Please check your Gemini API key.';
      case 429:
        return 'API quota exceeded. Please wait a moment and try again.';
      case 500:
      case 503:
        return 'Gemini service is temporarily unavailable. Try again shortly.';
      default:
        return 'Something went wrong (code $statusCode). Please try again.';
    }
  }

  void dispose() => _client.close();
}

class MedicalApiException implements Exception {
  final String message;
  const MedicalApiException(this.message);

  @override
  String toString() => message;
}