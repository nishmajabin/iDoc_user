import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/models/user_model.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat_screen.dart';

/// Drop this on any appointment detail screen.
/// Handles the "waiting" case where the doctor hasn't opened chat yet —
/// shows a clear message instead of an error.
class PatientChatButton extends StatefulWidget {
  final AppointmentModel appointment;
  final UserModel currentUser;

  const PatientChatButton({
    super.key,
    required this.appointment,
    required this.currentUser,
  });

  @override
  State<PatientChatButton> createState() => _PatientChatButtonState();
}

class _PatientChatButtonState extends State<PatientChatButton> {
  bool _loading = false;

  Future<void> _openChat() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      // Check if the doctor has already created the chat room.
      // The patient does NOT create the room — only the doctor does.
      final repo = UserChatRepository();
      final chatRoomId = repo.generateChatRoomId(
        doctorId: widget.appointment.doctorId,
        patientId: widget.appointment.userId,
        appointmentId: widget.appointment.appointmentId!,
      );

      // Navigate regardless — UserChatScreen handles the waiting state
      // gracefully when the room doesn't exist yet.
      if (!mounted) return;
      await Navigator.of(context).push(
        UserChatScreen.route(
          doctorId: widget.appointment.doctorId,
          patientId: widget.appointment.userId,
          appointmentId: widget.appointment.appointmentId!,
          doctorName: widget.appointment.doctorName,
          patientName: widget.currentUser.name,
          doctorProfileImageUrl: widget.appointment.doctorProfileImageUrl,
          patientProfileImageUrl: widget.currentUser.profileImageUrl,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Could not open chat. Please try again.',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD13D3D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF005F8E), Color(0xFF0077B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _loading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Chat with Doctor',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}