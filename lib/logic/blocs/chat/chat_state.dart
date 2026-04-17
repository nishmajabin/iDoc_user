import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/data/models/chat_room_model.dart';

abstract class UserChatState extends Equatable {
  const UserChatState();
  @override
  List<Object?> get props => [];
}

class UserChatInitial extends UserChatState {
  const UserChatInitial();
}

class UserChatLoading extends UserChatState {
  const UserChatLoading();
}

class UserChatWaiting extends UserChatState {
  const UserChatWaiting();
}

class UserChatLoaded extends UserChatState {
  final ChatRoomModel chatRoom;
  final List<ChatMessageModel> messages;
  final String patientId;
  final bool isSending;

  const UserChatLoaded({
    required this.chatRoom,
    required this.messages,
    required this.patientId,
    this.isSending = false,
  });

  UserChatLoaded copyWith({
    ChatRoomModel? chatRoom,
    List<ChatMessageModel>? messages,
    String? patientId,
    bool? isSending,
  }) =>
      UserChatLoaded(
        chatRoom: chatRoom ?? this.chatRoom,
        messages: messages ?? this.messages,
        patientId: patientId ?? this.patientId,
        isSending: isSending ?? this.isSending,
      );

  @override
  List<Object?> get props => [chatRoom, messages, patientId, isSending];
}

class UserChatError extends UserChatState {
  final String message;
  const UserChatError(this.message);
  @override
  List<Object?> get props => [message];
}