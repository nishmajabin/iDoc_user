import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/widgets/incoming_call_action_button.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/widgets/incoming_call_doctor_avatar.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/widgets/pulse_animator.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/widgets/slide_in_animator.dart';

class IncomingCallScreen extends StatelessWidget {
  final String doctorName;
  final String? doctorProfileImageUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallScreen({
    super.key,
    required this.doctorName,
    this.doctorProfileImageUrl,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── "Incoming Video Call" label ──────────────────────────
              const Text(
                'Incoming Video Call',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 28),

              // ── Avatar with continuous pulse animation ───────────────
              PulseAnimator(
                minScale: 1.0,
                maxScale: 1.15,
                duration: const Duration(milliseconds: 1500),
                child: IncomingCallDoctorAvatar(
                  doctorName: doctorName,
                  doctorProfileImageUrl: doctorProfileImageUrl,
                ),
              ),
              const SizedBox(height: 24),

              // ── Doctor name ─────────────────────────────────────────
              Text(
                doctorName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'wants to video call you',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),

              const Spacer(flex: 3),

              // ── Accept / Reject buttons with slide-in entrance ───────
              SlideInAnimator(
                begin: const Offset(0, 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IncomingCallActionButton(
                        icon: Icons.call_end_rounded,
                        label: 'Decline',
                        color: const Color(0xFFE53935),
                        onTap: onReject,
                      ),
                      IncomingCallActionButton(
                        icon: Icons.videocam_rounded,
                        label: 'Accept',
                        color: const Color(0xFF43A047),
                        onTap: onAccept,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
