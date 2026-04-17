import 'package:flutter/material.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/chat_ui/chat_ui_state.dart';


/// Cubit that owns the lifecycle of [TextEditingController] and
/// [ScrollController], replacing the two StatefulWidget classes that
/// previously managed them.
///
/// Responsibilities:
///  - Tracks whether the input field has non-empty text ([hasText]).
///  - Guards against duplicate message-stream subscriptions
///    ([messageStreamStarted]).
///  - Exposes [scrollToBottom] so callers never touch the controller directly.
///  - Disposes both controllers when the cubit is closed.
class ChatUICubit extends Cubit<ChatUIState> {
  ChatUICubit() : super(const ChatUIState()) {
    _inputController.addListener(_onInputChanged);
  }

  // ── Controllers ────────────────────────────────────────────────────────────

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Read-only access for the UI layer.
  TextEditingController get inputController => _inputController;
  ScrollController get scrollController => _scrollController;

  // ── Private helpers ────────────────────────────────────────────────────────

  void _onInputChanged() {
    final has = _inputController.text.trim().isNotEmpty;
    if (has != state.hasText) {
      emit(state.copyWith(hasText: has));
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Clears the text field (called after a message is dispatched).
  void clearInput() => _inputController.clear();

  /// Marks that the real-time message stream has been started so we never
  /// subscribe twice when the BLoC rebuilds.
  void markMessageStreamStarted() {
    if (!state.messageStreamStarted) {
      emit(state.copyWith(messageStreamStarted: true));
    }
  }

  /// Smoothly scrolls the message list to the most recent message.
  /// Uses a post-frame callback so it runs after the list has been laid out.
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _scrollController.dispose();
    return super.close();
  }
}