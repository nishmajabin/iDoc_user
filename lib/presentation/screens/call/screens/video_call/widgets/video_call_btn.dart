import 'package:flutter/material.dart';

class VideoCallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final double size;

  const VideoCallBtn({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
    this.size = 52,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onTap == null ? Colors.white12 : bg,
              shape: BoxShape.circle,
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                        color: bg.withValues(alpha: .4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: fg, size: size * 0.42),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onTap == null ? Colors.white38 : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}