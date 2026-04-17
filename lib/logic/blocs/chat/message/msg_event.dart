
abstract class MsgEvent {}

class StartMessages extends MsgEvent {
  final String chatRoomId;
  StartMessages(this.chatRoomId);
}