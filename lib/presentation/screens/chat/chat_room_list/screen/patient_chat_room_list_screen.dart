import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/patient_chat_list_view.dart';

class PatientChatRoomListScreen extends StatelessWidget {
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const PatientChatRoomListScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientChatListBloc(repository: UserChatRepository())
        ..add(WatchPatientChatRooms(patientId)),
      child: PatientChatListView(
        patientId: patientId,
        patientName: patientName,
        patientProfileImageUrl: patientProfileImageUrl,
      ),
    );
  }
}
