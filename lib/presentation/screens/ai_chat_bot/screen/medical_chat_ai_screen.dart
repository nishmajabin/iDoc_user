import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/chat_screen_cubit.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_body.dart';
import 'package:image_picker/image_picker.dart';

class MedicalChatScreen extends StatelessWidget {
  const MedicalChatScreen({super.key});

  static final textController   = TextEditingController();
  static final scrollController = ScrollController();
  static final focusNode        = FocusNode();
  static final imagePicker      = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatScreenCubit(),
      child: const MedicalChatBody(),
    );
  }
}