import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';
import 'package:idoc_user/logic/blocs/chat/chat_event.dart';
import 'package:idoc_user/logic/blocs/chat/chat_state.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_event.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_state.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_stream_bloc.dart';
import 'package:idoc_user/logic/cubits/chat_ui/chat_ui_cubit.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/states/user_chat_empty_view.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/states/user_chat_error_view.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/states/user_chat_loading_view.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/states/user_chat_waiting_view.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_app_bar.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_input_bar.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_message_list.dart';

class UserChatView extends StatelessWidget {
  final String patientId;
  final String? doctorName;
  final String? doctorProfileImageUrl;

  const UserChatView({
    required this.patientId,
    this.doctorName,
    this.doctorProfileImageUrl,
    super.key
  });

  void _sendMessage(BuildContext context) {
    final cubit = context.read<ChatUICubit>();
    final text = cubit.inputController.text.trim();
    if (text.isEmpty) return;
    cubit.clearInput();
    context.read<UserChatBloc>().add(SendUserMessage(text));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgChat,
        body: Column(
          children: [
            // ── App bar ─────────────────────────────────────────────────────
            UserChatAppBar(
              doctorName: doctorName,
              avatarUrl: doctorProfileImageUrl,
            ),

            // ── Main content ─────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<UserChatBloc, UserChatState>(
                listener: (context, state) {
                  if (state is UserChatLoaded) {
                    final uiCubit = context.read<ChatUICubit>();

                    // Start message stream only once
                    if (!uiCubit.state.messageStreamStarted) {
                      uiCubit.markMessageStreamStarted();
                      context
                          .read<MessageStreamBloc>()
                          .add(StartMessages(state.chatRoom.chatRoomId));
                    }

                    // Mark messages as read immediately when screen opens
                    context
                        .read<UserChatBloc>()
                        .add(const MarkUserMessagesRead());
                  }
                },
                builder: (context, chatState) {
                  if (chatState is UserChatLoading) return const UserChatLoadingView();
                  if (chatState is UserChatWaiting) return const UserChatWaitingView();
                  if (chatState is UserChatError) {
                    return UserChatErrorView(message: chatState.message);
                  }
                  if (chatState is UserChatLoaded) {
                    return BlocConsumer<MessageStreamBloc, MsgState>(
                      listener: (_, msgState) {
                        if (msgState is MsgLoaded) {
                          context.read<ChatUICubit>().scrollToBottom();
                        }
                      },
                      builder: (_, msgState) {
                        final messages = msgState is MsgLoaded
                            ? msgState.messages
                            : chatState.messages;

                        if (messages.isEmpty) return const UserChatEmptyView();

                        return UserChatMessageList(
                          messages: messages,
                          patientId: patientId,
                          // Controller is owned by ChatUICubit — no dispose concern
                          scrollCtrl:
                              context.read<ChatUICubit>().scrollController,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Input bar ────────────────────────────────────────────────────
            BlocBuilder<UserChatBloc, UserChatState>(
              builder: (context, chatState) {
                final canSend = chatState is UserChatLoaded;
                final isSending =
                    chatState is UserChatLoaded ? chatState.isSending : false;

                return UserChatInputBar(
                  // Controller reference never changes — safe to pass directly
                  controller: context.read<ChatUICubit>().inputController,
                  onSend: canSend ? () => _sendMessage(context) : null,
                  isSending: isSending,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}