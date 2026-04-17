import 'package:idoc_user/data/models/chat_message_model.dart';

abstract class MsgState {}

class MsgInitial extends MsgState {}

class MsgLoaded extends MsgState {
  final List<ChatMessageModel> messages;
  MsgLoaded(this.messages);
}
