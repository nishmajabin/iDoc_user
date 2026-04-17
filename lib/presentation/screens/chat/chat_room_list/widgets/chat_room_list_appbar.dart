import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/chat_room_patient_initial.dart';

class ChatRoomListAppBar extends StatelessWidget {
  final String? patientName;
  final String? avatarUrl;

  const ChatRoomListAppBar({this.patientName, this.avatarUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
          top: topPad + 12, bottom: 16, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF005F8E), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Your doctor consultations',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(avatarUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ChatRoomPatientInitial(
                            name: patientName))
                  : ChatRoomPatientInitial(name: patientName),
            ),
          ),
        ],
      ),
    );
  }
}