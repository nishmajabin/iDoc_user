import 'package:flutter/material.dart';

class VideoCallMsg extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool spin;
  final Color iconColor;

  const VideoCallMsg({
    required this.icon,
    required this.title,
    required this.sub,
    this.spin = false,
    this.iconColor = Colors.white70,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: const Color(0xCC0D0D0D),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  sub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              if (spin) ...[
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white38,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}