import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/thinking_bubble_cubit.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/thinking_bubbler_state.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/thinking_dot.dart';

class ThinkingDotsBubble extends StatelessWidget {
  const ThinkingDotsBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.aiBubble,
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(20),
          topRight:    Radius.circular(20),
          bottomLeft:  Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: BlocBuilder<ThinkingBubbleCubit, ThinkingBubbleState>(
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => ThinkingDot(offset: state.offsets[i]),
            ),
          );
        },
      ),
    );
  }
}