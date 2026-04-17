import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:idoc_user/logic/blocs/ai_chat_bot/ai_chat_bot_state.dart';

class MedicalChatAppbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClear;
  const MedicalChatAppbar({required this.onClear, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation:       0,
      centerTitle:     false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size:  20,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.layerBlurColor2],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:     AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset:    const Offset(0, 2),
                ),
              ],
            ),
            child:  Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.gradientColor,
              size:  22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:       MainAxisSize.min,
            children: [
              Text(
                'Medical AI',
                style: TextStyle(
                  color:       AppColors.textPrimary,
                  fontWeight:  FontWeight.w700,
                  fontSize:    16,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius:          4,
                    backgroundColor: AppColors.circleBgColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Online',
                    style: TextStyle(
                      color:      AppColors.textSecondary,
                      fontSize:   11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        BlocBuilder<MedicalChatBloc, MedicalChatState>(
          builder: (context, state) {
            if (state.messages.length <= 1) return const SizedBox.shrink();
            return IconButton(
              tooltip:   'Clear conversation',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size:  22,
              ),
              onPressed: onClear,
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }
}