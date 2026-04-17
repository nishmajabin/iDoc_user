import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_event.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_state.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/chat_screen_cubit.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/screen/medical_chat_ai_screen.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_appbar.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_image_source_sheet.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_input_bar.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/message_bubble.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/pending_image_preview.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/thinking_bubble.dart';
import 'package:image_picker/image_picker.dart';

class MedicalChatBody extends StatelessWidget {
  const MedicalChatBody({super.key});

  void _scrollToBottom(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sc = MedicalChatScreen.scrollController;
      if (sc.hasClients) {
        sc.animateTo(
          sc.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MedicalChatImageSourceSheet(
        onGallery: () async {
          Navigator.pop(context);
          final file = await MedicalChatScreen.imagePicker.pickImage(
            source:       ImageSource.gallery,
            imageQuality: 85,
            maxWidth:     1280,
          );
          if (file != null && context.mounted) {
            final bytes = await file.readAsBytes();
            // ignore: use_build_context_synchronously
            context.read<MedicalChatBloc>().add(ImageAttachedEvent(bytes));
          }
        },
        onCamera: () async {
          Navigator.pop(context);
          final file = await MedicalChatScreen.imagePicker.pickImage(
            source:       ImageSource.camera,
            imageQuality: 85,
            maxWidth:     1280,
          );
          if (file != null && context.mounted) {
            final bytes = await file.readAsBytes();
            // ignore: use_build_context_synchronously
            context.read<MedicalChatBloc>().add(ImageAttachedEvent(bytes));
          }
        },
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final bloc  = context.read<MedicalChatBloc>();
    final state = bloc.state;
    final text  = MedicalChatScreen.textController.text.trim();

    if (state.pendingImage != null) {
      bloc.add(SendMedicalImageEvent(
        imageBytes: state.pendingImage!,
        caption:    text.isNotEmpty ? text : null,
      ));
    } else if (text.isNotEmpty) {
      bloc.add(SendMedicalTextEvent(text));
    } else {
      return;
    }

    MedicalChatScreen.textController.clear();
    MedicalChatScreen.focusNode.requestFocus();
    context.read<ChatScreenCubit>().scrollToBottom();
  }

  void _showClearConfirm(BuildContext context) {
    // Pre-capture bloc before dialog opens so dialogCtx doesn't need it
    final bloc = context.read<MedicalChatBloc>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear conversation?',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'All messages will be deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              bloc.add(const ClearMedicalChatEvent());
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(
                    color:      AppColors.errorText,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Listen to ChatScreenCubit scroll signals ────────────────────
    return BlocListener<ChatScreenCubit, int>(
      listener: (context, _) => _scrollToBottom(context),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: MedicalChatAppbar(
          onClear: () => _showClearConfirm(context),
        ),
        body: Column(
          children: [
            // ── Messages list ───────────────────────────────────────
            Expanded(
              child: BlocConsumer<MedicalChatBloc, MedicalChatState>(
                listener: (context, state) {
                  if (state is MedicalChatLoaded ||
                      state is MedicalChatError) {
                    context.read<ChatScreenCubit>().scrollToBottom();
                  }
                },
                builder: (context, state) {
                  final messages  = state.messages;
                  final isLoading = state is MedicalChatLoading;

                  return ListView.builder(
                    controller: MedicalChatScreen.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {
                        return const ThinkingBubble();
                      }
                      return MessageBubble(
                        message: messages[index],
                        key:     ValueKey(messages[index].id),
                      );
                    },
                  );
                },
              ),
            ),

            // ── Pending image preview ───────────────────────────────
            BlocBuilder<MedicalChatBloc, MedicalChatState>(
              builder: (context, state) {
                if (state.pendingImage == null) {
                  return const SizedBox.shrink();
                }
                return PendingImagePreview(
                  imageBytes: state.pendingImage!,
                  onRemove:   () => context
                      .read<MedicalChatBloc>()
                      .add(const ImageRemovedEvent()),
                );
              },
            ),

            // ── Input bar ───────────────────────────────────────────
            BlocBuilder<MedicalChatBloc, MedicalChatState>(
              builder: (context, state) {
                return MedicalChatInputBar(
                  controller:      MedicalChatScreen.textController,
                  focusNode:       MedicalChatScreen.focusNode,
                  isLoading:       state is MedicalChatLoading,
                  hasPendingImage: state.pendingImage != null,
                  onAttach:        () => _pickImage(context),
                  onSend:          () => _sendMessage(context),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}