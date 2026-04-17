class ChatInputState {
  final bool hasText;
  final DateTime? lastSentAt;

  const ChatInputState({
    this.hasText = false,
    this.lastSentAt,
  });

  ChatInputState copyWith({
    bool? hasText,
    DateTime? lastSentAt,
  }) {
    return ChatInputState(
      hasText:    hasText    ?? this.hasText,
      lastSentAt: lastSentAt ?? this.lastSentAt,
    );
  }
}