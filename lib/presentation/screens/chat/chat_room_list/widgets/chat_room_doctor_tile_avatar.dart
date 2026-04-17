import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRoomDoctorTileAvatar extends StatelessWidget {
  final String name;
  const ChatRoomDoctorTileAvatar({required this.name, super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'D',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
      );
}
