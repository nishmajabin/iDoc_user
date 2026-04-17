import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_event.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_state.dart';

class MessageStreamBloc extends Bloc<MsgEvent, MsgState> {
  final UserChatRepository _repo;

  MessageStreamBloc(this._repo) : super(MsgInitial()) {
    on<StartMessages>(_onStart);
  }

  Future<void> _onStart(StartMessages event, Emitter<MsgState> emit) async {
    await emit.forEach<List<ChatMessageModel>>(
      _repo.watchMessages(event.chatRoomId),
      onData: (msgs) => MsgLoaded(msgs),
      onError: (_, __) => MsgInitial(),
    );
  }
}