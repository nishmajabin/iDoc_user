import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/thinking_avatar.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/thinking_dot_bubble.dart';

class ThinkingBubbleView extends StatelessWidget {
  const ThinkingBubbleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ThinkingAvatar(),
          ThinkingDotsBubble(),
        ],
      ),
    );
  }
}
