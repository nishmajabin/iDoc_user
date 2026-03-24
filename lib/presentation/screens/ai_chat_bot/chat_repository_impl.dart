import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:idoc_user/data/services/ai_chat/chat_api_service.dart';
import 'package:idoc_user/data/services/ai_chat/medical_api_exception.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_ai_repository.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
import 'package:uuid/uuid.dart';

/// Repository that tries [_primary] (Groq) first, then automatically
/// falls back to [_fallback] (OpenRouter) when:
///   • The primary returns a non-200 status code
///   • A 429 (Too Many Requests) error occurs
///   • Any unexpected exception is thrown
///
/// The consumer (BLoC / use-case) never needs to know which provider
/// ultimately handled the request.
class MedicalChatRepositoryImpl implements MedicalChatRepository {
  final ChatApiService _primary;
  final ChatApiService _fallback;
  static const _uuid = Uuid();

  const MedicalChatRepositoryImpl({
    required ChatApiService primary,
    required ChatApiService fallback,
  })  : _primary = primary,
        _fallback = fallback;

  @override
  Future<MedicalChatMessage> sendMessage({
    required String prompt,
    required List<MedicalChatMessage> history,
  }) async {
    final messageId = _uuid.v4();

    try {
      debugPrint('[ChatRepo] Trying ${_primary.providerName}...');
      return await _primary.sendMessage(
        prompt: prompt,
        history: history,
        responseMessageId: messageId,
      );
    } on MedicalApiException catch (e) {
      debugPrint(
          '[ChatRepo] ${_primary.providerName} failed (${e.statusCode}): $e');

      // Fall back to secondary provider
      return _tryFallback(
        () => _fallback.sendMessage(
          prompt: prompt,
          history: history,
          responseMessageId: messageId,
        ),
        primaryError: e,
      );
    } catch (e) {
      debugPrint('[ChatRepo] ${_primary.providerName} unexpected error: $e');

      return _tryFallback(
        () => _fallback.sendMessage(
          prompt: prompt,
          history: history,
          responseMessageId: messageId,
        ),
        primaryError: MedicalApiException(e.toString()),
      );
    }
  }

  @override
  Future<MedicalChatMessage> sendImageMessage({
    required Uint8List imageBytes,
    String? prompt,
    required List<MedicalChatMessage> history,
  }) async {
    final messageId = _uuid.v4();

    try {
      debugPrint('[ChatRepo] Trying ${_primary.providerName} (image)...');
      return await _primary.sendImageMessage(
        imageBytes: imageBytes,
        prompt: prompt,
        history: history,
        responseMessageId: messageId,
      );
    } on MedicalApiException catch (e) {
      debugPrint(
          '[ChatRepo] ${_primary.providerName} image failed (${e.statusCode}): $e');

      return _tryFallback(
        () => _fallback.sendImageMessage(
          imageBytes: imageBytes,
          prompt: prompt,
          history: history,
          responseMessageId: messageId,
        ),
        primaryError: e,
      );
    } catch (e) {
      debugPrint(
          '[ChatRepo] ${_primary.providerName} image unexpected error: $e');

      return _tryFallback(
        () => _fallback.sendImageMessage(
          imageBytes: imageBytes,
          prompt: prompt,
          history: history,
          responseMessageId: messageId,
        ),
        primaryError: MedicalApiException(e.toString()),
      );
    }
  }

  /// Attempt the fallback provider. If it also fails, throw the **fallback**
  /// error (since the primary error was already logged).
  Future<MedicalChatMessage> _tryFallback(
    Future<MedicalChatMessage> Function() fallbackCall, {
    required MedicalApiException primaryError,
  }) async {
    try {
      debugPrint(
          '[ChatRepo] Falling back to ${_fallback.providerName}...');
      return await fallbackCall();
    } on MedicalApiException {
      // Both providers failed — rethrow the fallback error
      rethrow;
    } catch (e) {
      // If fallback also threw something unexpected, wrap it
      throw MedicalApiException(
        'Both AI providers failed. Please try again later.\n'
        '${_primary.providerName}: ${primaryError.message}\n'
        '${_fallback.providerName}: $e',
      );
    }
  }

  void dispose() {
    _primary.dispose();
    _fallback.dispose();
  }
}