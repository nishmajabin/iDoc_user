import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/chat_ui/chat_ui_cubit.dart';
import 'package:idoc_user/logic/cubits/chat_ui/chat_ui_state.dart';

class UserChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isSending;

  const UserChatInputBar({
    required this.controller,
    this.onSend,
    this.isSending = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // BlocBuilder scoped to ChatUICubit so only the send-button re-renders
    // when the user types — the rest of the widget tree is untouched.
    return BlocBuilder<ChatUICubit, ChatUIState>(
      buildWhen: (prev, curr) => prev.hasText != curr.hasText,
      builder: (context, uiState) {
        final hasText = uiState.hasText;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 12,
            top: 10,
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Text field ────────────────────────────────────────────────
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    enabled: onSend != null,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: onSend != null
                          ? 'Type a message...'
                          : 'Chat not available yet',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── Send button ───────────────────────────────────────────────
              AnimatedScale(
                scale: hasText ? 1.0 : 0.85,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: GestureDetector(
                  onTap: hasText && !isSending ? onSend : null,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasText
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color:
                          hasText ? null : AppColors.textMuted.withOpacity(0.3),
                    ),
                    child: isSending
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
