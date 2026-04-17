import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/input_bar_cubit.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_input_bar_body.dart';

class MedicalChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool hasPendingImage;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const MedicalChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.hasPendingImage,
    required this.onAttach,
    required this.onSend,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InputBarCubit()
        ..onTextChanged(controller.text), // sync initial value
      child: MedicalChatInputBarBody(
        controller:      controller,
        focusNode:       focusNode,
        isLoading:       isLoading,
        hasPendingImage: hasPendingImage,
        onAttach:        onAttach,
        onSend:          onSend,
      ),
    );
  }
}