import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/chat_room_empty_inbox_view.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/chat_room_list_appbar.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/chat_room_tile.dart';

class PatientChatListView extends StatelessWidget {
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const PatientChatListView({
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            ChatRoomListAppBar(
              patientName: patientName,
              avatarUrl: patientProfileImageUrl,
            ),
            Expanded(
              child: BlocBuilder<PatientChatListBloc, PatientChatListState>(
                builder: (context, state) {
                  if (state is PatientChatListLoading ||
                      state is PatientChatListInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is PatientChatListError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFFE05C5C)),
                      ),
                    );
                  }
                  if (state is PatientChatListLoaded) {
                    if (state.rooms.isEmpty) {
                      return const ChatRoomEmptyInboxView();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: state.rooms.length,
                      itemBuilder: (_, i) => ChatRoomTile(
                        room: state.rooms[i],
                        patientId: patientId,
                        patientName: patientName,
                        patientProfileImageUrl: patientProfileImageUrl,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}