import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_event.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_state.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/send_message_usecase.dart';
import 'package:uuid/uuid.dart';

class MedicalChatBloc extends Bloc<MedicalChatEvent, MedicalChatState> {
  final SendMedicalMessageUseCase _sendMessage;
  final SendMedicalImageMessageUseCase _sendImageMessage;
  static const _uuid = Uuid();

  // ── Request guard ─────────────────────────────────────────────────────────
  bool _isProcessing = false;

  // ── Debounce timer (800 ms) ───────────────────────────────────────────────
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 800);

  // ── Welcome message ───────────────────────────────────────────────────────

  static MedicalChatMessage _buildWelcome() => MedicalChatMessage(
        id: 'welcome',
        text: 'Hello! I am your Medical AI Assistant. '
            'Ask me any health-related question or upload a medical image for analysis. '
            'Remember, I provide general guidance only — always consult your doctor.',
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
      );

  MedicalChatBloc({
    required SendMedicalMessageUseCase sendMessage,
    required SendMedicalImageMessageUseCase sendImageMessage,
  })  : _sendMessage = sendMessage,
        _sendImageMessage = sendImageMessage,
        super(MedicalChatInitial(messages: [_buildWelcome()])) {
    on<SendMedicalTextEvent>(_onSendText);
    on<SendMedicalImageEvent>(_onSendImage);
    on<ImageAttachedEvent>(_onImageAttached);
    on<ImageRemovedEvent>(_onImageRemoved);
    on<ClearMedicalChatEvent>(_onClearChat);
  }

  // ── Text message (with 800ms debounce) ─────────────────────────────────

  Future<void> _onSendText(
    SendMedicalTextEvent event,
    Emitter<MedicalChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    // Synchronous guard — prevents concurrent requests
    if (_isProcessing) return;
    _isProcessing = true;

    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    final userMsg = MedicalChatMessage(
      id: _uuid.v4(),
      text: event.message.trim(),
      role: ChatRole.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMsg];
    emit(MedicalChatLoading(messages: updatedMessages, pendingImage: null));

    // ── Debounce delay: wait 800ms before actually sending ──────────────
    await Future.delayed(_debounceDuration);

    try {
      final response = await _sendMessage.call(
        prompt: event.message.trim(),
        history: state.messages
            .where((m) => !m.isError && m.hasText && !m.hasImage)
            .toList(),
      );
      emit(MedicalChatLoaded(
        messages: [...updatedMessages, response],
        pendingImage: null,
      ));
    } catch (e) {
      final errorMsg = MedicalChatMessage(
        id: _uuid.v4(),
        text: _friendlyError(e.toString()),
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );
      emit(MedicalChatError(
        messages: [...updatedMessages, errorMsg],
        errorMessage: e.toString(),
      ));
    } finally {
      _isProcessing = false;
    }
  }

  // ── Image message (with 800ms debounce) ────────────────────────────────

  Future<void> _onSendImage(
    SendMedicalImageEvent event,
    Emitter<MedicalChatState> emit,
  ) async {
    if (_isProcessing) return;
    _isProcessing = true;

    _debounceTimer?.cancel();

    final userMsg = MedicalChatMessage(
      id: _uuid.v4(),
      text: event.caption,
      imageBytes: event.imageBytes,
      role: ChatRole.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMsg];
    emit(MedicalChatLoading(messages: updatedMessages, pendingImage: null));

    // ── Debounce delay ──────────────────────────────────────────────────
    await Future.delayed(_debounceDuration);

    try {
      final response = await _sendImageMessage.call(
        imageBytes: event.imageBytes,
        prompt: event.caption,
        history: state.messages
            .where((m) => !m.isError && m.hasText && !m.hasImage)
            .toList(),
      );
      emit(MedicalChatLoaded(
        messages: [...updatedMessages, response],
        pendingImage: null,
      ));
    } catch (e) {
      final errorMsg = MedicalChatMessage(
        id: _uuid.v4(),
        text: _friendlyError(e.toString()),
        role: ChatRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      );
      emit(MedicalChatError(
        messages: [...updatedMessages, errorMsg],
        errorMessage: e.toString(),
      ));
    } finally {
      _isProcessing = false;
    }
  }

  // ── Image attachment management ───────────────────────────────────────────

  void _onImageAttached(
      ImageAttachedEvent event, Emitter<MedicalChatState> emit) {
    emit(_rebuildWithImage(state, event.imageBytes));
  }

  void _onImageRemoved(
      ImageRemovedEvent event, Emitter<MedicalChatState> emit) {
    emit(_rebuildWithImage(state, null));
  }

  void _onClearChat(
      ClearMedicalChatEvent event, Emitter<MedicalChatState> emit) {
    _isProcessing = false;
    _debounceTimer?.cancel();
    emit(MedicalChatInitial(messages: [_buildWelcome()]));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  MedicalChatState _rebuildWithImage(
      MedicalChatState current, Uint8List? image) {
    if (current is MedicalChatInitial) {
      return MedicalChatInitial(
          messages: current.messages, pendingImage: image);
    }
    if (current is MedicalChatLoaded) {
      return MedicalChatLoaded(
          messages: current.messages, pendingImage: image);
    }
    if (current is MedicalChatError) {
      return MedicalChatError(
        messages: current.messages,
        errorMessage: current.errorMessage,
        pendingImage: image,
      );
    }
    return current;
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('internet') ||
        lower.contains('host')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (lower.contains('invalid') && lower.contains('api key')) {
      return 'Invalid API key. Please check your API key configuration.';
    }
    if (lower.contains('api key') ||
        lower.contains('401') ||
        lower.contains('403') ||
        lower.contains('unauthorized')) {
      return 'API key error. Please verify your API key.';
    }
    if (lower.contains('both ai providers failed')) {
      return 'Both AI services are currently unavailable. Please try again later.';
    }
    if (lower.contains('429') ||
        lower.contains('quota') ||
        lower.contains('rate limit')) {
      return 'API rate limit reached. Please wait a moment and try again.';
    }
    if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return raw.isNotEmpty ? raw : 'Something went wrong. Please try again.';
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}