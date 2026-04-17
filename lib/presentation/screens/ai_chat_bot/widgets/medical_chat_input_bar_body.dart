import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/input_bar_cubit.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_circle_button.dart';

class MedicalChatInputBarBody extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool hasPendingImage;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const MedicalChatInputBarBody({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.hasPendingImage,
    required this.onAttach,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Wire controller changes into cubit — addListener is idempotent
    // so this is safe to call in build.
    controller.addListener(() {
      context.read<InputBarCubit>().onTextChanged(controller.text);
    });

    return BlocBuilder<InputBarCubit, bool>(
      builder: (context, hasText) {
        final canSend = (hasText || hasPendingImage) && !isLoading;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            border: const Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── Attach button ──────────────────────────────────────
                  MedicalChatCircleButton(
                    onTap: isLoading ? null : onAttach,
                    tooltip: 'Attach image',
                    isActive: hasPendingImage,
                    child: Icon(
                      hasPendingImage
                          ? Icons.image_rounded
                          : Icons.add_photo_alternate_outlined,
                      color:
                          hasPendingImage
                              ? AppColors.accent
                              : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Text field ─────────────────────────────────────────
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: AppColors.gradientColor,
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              hasPendingImage
                                  ? 'Describe this image (optional)...'
                                  : 'Ask a medical question...',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.divider,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.divider,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ── Send button ────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          canSend
                              ?  LinearGradient(
                                colors: [AppColors.linearGradientColor, AppColors.layerBlurColor2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : null,
                      color: canSend ? null : AppColors.divider,
                      boxShadow:
                          canSend
                              ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                              : null,
                    ),
                    child: Material(
                      color: AppColors.transparentColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: canSend ? onSend : null,
                        child: Center(
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                  :  Icon(
                                    Icons.send_rounded,
                                    color: AppColors.bgColor,
                                    size: 19,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
