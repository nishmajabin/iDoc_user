import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/thinking_bubble_cubit.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/thinking_bubble_view.dart';

class ThinkingBubble extends StatelessWidget {
  const ThinkingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThinkingBubbleCubit(),
      child: const ThinkingBubbleView(),
    );
  }
}