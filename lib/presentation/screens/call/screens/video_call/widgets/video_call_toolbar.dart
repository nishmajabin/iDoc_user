import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_btn.dart';

class VideoCallToolbar extends StatelessWidget {
  final bool isMuted;
  final bool enabled;
  final VoidCallback onMute;
  final VoidCallback onEnd;
  final VoidCallback onFlip;

  const VideoCallToolbar({
    required this.isMuted,
    required this.enabled,
    required this.onMute,
    required this.onEnd,
    required this.onFlip,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(bottom: 30, top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            VideoCallBtn(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: isMuted ? 'Unmute' : 'Mute',
              bg: isMuted ? Colors.white : Colors.white24,
              fg: isMuted ? Colors.black : Colors.white,
              onTap: enabled ? onMute : null,
            ),
            VideoCallBtn(
              icon: Icons.call_end_rounded,
              label: 'End',
              bg: Colors.red,
              fg: Colors.white,
              size: 64,
              onTap: onEnd,
            ),
            VideoCallBtn(
              icon: Icons.flip_camera_ios_rounded,
              label: 'Flip',
              bg: Colors.white24,
              fg: Colors.white,
              onTap: enabled ? onFlip : null,
            ),
          ],
        ),
      ),
    );
  }
}
