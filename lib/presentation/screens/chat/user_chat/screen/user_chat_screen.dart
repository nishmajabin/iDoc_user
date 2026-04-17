import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';
import 'package:idoc_user/logic/blocs/chat/chat_event.dart';
import 'package:idoc_user/logic/blocs/chat/message/msg_stream_bloc.dart';
import 'package:idoc_user/logic/cubits/chat_ui/chat_ui_cubit.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_view.dart';

class UserChatScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? doctorName;
  final String? patientName;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;

  const UserChatScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.doctorName,
    this.patientName,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
  });

  static Route<void> route({
    required String doctorId,
    required String patientId,
    required String appointmentId,
    String? doctorName,
    String? patientName,
    String? doctorProfileImageUrl,
    String? patientProfileImageUrl,
  }) =>
      MaterialPageRoute(
        builder: (_) => UserChatScreen(
          doctorId: doctorId,
          patientId: patientId,
          appointmentId: appointmentId,
          doctorName: doctorName,
          patientName: patientName,
          doctorProfileImageUrl: doctorProfileImageUrl,
          patientProfileImageUrl: patientProfileImageUrl,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Drives chat-room initialisation and message sending
        BlocProvider(
          create: (_) => UserChatBloc()
            ..add(InitializeUserChat(
              doctorId: doctorId,
              patientId: patientId,
              appointmentId: appointmentId,
              doctorName: doctorName,
              patientName: patientName,
              doctorProfileImageUrl: doctorProfileImageUrl,
              patientProfileImageUrl: patientProfileImageUrl,
            )),
        ),
        // Streams messages sub-collection in real time
        BlocProvider(
          create: (_) => MessageStreamBloc(UserChatRepository()),
        ),
        // Owns TextEditingController, ScrollController, and transient UI flags
        BlocProvider(
          create: (_) => ChatUICubit(),
        ),
      ],
      child: UserChatView(
        patientId: patientId,
        doctorName: doctorName,
        doctorProfileImageUrl: doctorProfileImageUrl,
      ),
    );
  }
}
