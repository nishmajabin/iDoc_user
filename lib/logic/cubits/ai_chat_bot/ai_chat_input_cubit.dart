import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/ai_chat_input_state.dart';

class ChatInputCubit extends Cubit<ChatInputState> {
  ChatInputCubit() : super(const ChatInputState());

  static const _sendDebounce = Duration(milliseconds: 300);

  void onTextChanged(String text) {
    final hasText = text.trim().isNotEmpty;
    if (hasText != state.hasText) {
      emit(state.copyWith(hasText: hasText));
    }
  }

  /// Returns true if send should proceed, false if debounced.
  bool tryMarkSent() {
    final now = DateTime.now();
    if (state.lastSentAt != null &&
        now.difference(state.lastSentAt!) < _sendDebounce) {
      return false;
    }
    emit(state.copyWith(lastSentAt: now));
    return true;
  }

  void clearText() {
    emit(state.copyWith(hasText: false));
  }
}