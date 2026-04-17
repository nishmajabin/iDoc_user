import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/ai_chat_input_cubit.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/ai_chat_input_state.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/chat_input_attach_button.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/chat_input_send_button.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/chat_input_source_tile.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/image_preview_strip.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatelessWidget {
  final void Function(String message, {Uint8List? imageBytes}) onSend;
  final void Function(Uint8List bytes)? onImagePicked;
  final bool isLoading;
  final Uint8List? pendingImage;
  final VoidCallback? onImageRemoved;

  // UI-only objects — not state, safe as static finals
  static final _controller = TextEditingController();
  static final _focusNode  = FocusNode();
  static final _picker     = ImagePicker();

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onImagePicked,
    this.isLoading = false,
    this.pendingImage,
    this.onImageRemoved,
  });

  bool _canSend(bool hasText) =>
      (hasText || pendingImage != null) && !isLoading;

  void _send(BuildContext context) {
    final cubit = context.read<ChatInputCubit>();
    if (!_canSend(cubit.state.hasText)) return;
    if (!cubit.tryMarkSent()) return; // debounced

    final text = _controller.text.trim();
    final effectiveText =
        text.isNotEmpty ? text : 'Please analyze this medical image.';

    onSend(effectiveText, imageBytes: pendingImage);
    _controller.clear();
    cubit.clearText();
    _focusNode.requestFocus();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source:       source,
        imageQuality: 85,
        maxWidth:     1280,
        maxHeight:    1280,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      onImagePicked?.call(bytes);
    } catch (_) {
      // Permission denied or picker cancelled — ignore silently.
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attach Image',
                style: TextStyle(
                  fontSize:   17,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a medical image for AI analysis',
                style: TextStyle(fontSize: 13, color: AppColors.skipColor),
              ),
              const SizedBox(height: 20),
              ChatInputSourceTile(
                icon:  Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              ChatInputSourceTile(
                icon:  Icons.camera_alt_rounded,
                label: 'Take a Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatInputCubit()
        ..onTextChanged(_controller.text), // sync initial state
      child: Builder(
        builder: (context) {
          // Wire controller changes into cubit
          _controller.addListener(() {
            context.read<ChatInputCubit>().onTextChanged(_controller.text);
          });

          return BlocBuilder<ChatInputCubit, ChatInputState>(
            builder: (context, state) {
              final canSend = _canSend(state.hasText);

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  boxShadow: [
                    BoxShadow(
                      color:     AppColors.shadowDark.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset:    const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Pending image preview strip ──────────────────
                      if (pendingImage != null)
                        ImagePreviewStrip(
                          imageBytes: pendingImage!,
                          onRemove:   onImageRemoved,
                        ),

                      // ── Input row ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ChatInputAttachButton(
                              onTap:    isLoading ? null : () => _showImageSourceSheet(context),
                              hasImage: pendingImage != null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 120),
                                decoration: BoxDecoration(
                                  color:        AppColors.bgColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: TextField(
                                  controller:          _controller,
                                  focusNode:           _focusNode,
                                  maxLines:            null,
                                  textCapitalization:  TextCapitalization.sentences,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:    AppColors.gradientColor,
                                    height:   1.4,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: pendingImage != null
                                        ? 'Ask about this image...'
                                        : 'Ask me about your health...',
                                    hintStyle: TextStyle(
                                      color:    AppColors.skipColor,
                                      fontSize: 15,
                                    ),
                                    border:         InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical:   12,
                                    ),
                                  ),
                                  onSubmitted:     (_) => _send(context),
                                  textInputAction: TextInputAction.newline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ChatInputSendButton(
                              canSend:   canSend,
                              isLoading: isLoading,
                              onTap:     () => _send(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}