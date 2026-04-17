import 'package:flutter/material.dart';

class MyAppoinmentMetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color surface;

  const MyAppoinmentMetaChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.surface,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}