import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRoomPatientInitial extends StatelessWidget {
  final String? name;
  const ChatRoomPatientInitial({this.name, super.key});
  @override
  Widget build(BuildContext context) {
    final i =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'P';
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Text(i,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
    );
  }
}