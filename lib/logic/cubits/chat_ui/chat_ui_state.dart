
import 'package:equatable/equatable.dart';

/// Immutable state owned by [ChatUICubit].
///
/// Holds every piece of transient UI state that previously lived inside
/// StatefulWidget instances:
///  - [hasText]               → drives Send-button active/inactive appearance
///  - [messageStreamStarted]  → prevents duplicate stream subscriptions
final class ChatUIState extends Equatable {
  const ChatUIState({
    this.hasText = false,
    this.messageStreamStarted = false,
  });

  final bool hasText;
  final bool messageStreamStarted;

  ChatUIState copyWith({
    bool? hasText,
    bool? messageStreamStarted,
  }) =>
      ChatUIState(
        hasText: hasText ?? this.hasText,
        messageStreamStarted: messageStreamStarted ?? this.messageStreamStarted,
      );

  @override
  List<Object?> get props => [hasText, messageStreamStarted];
}