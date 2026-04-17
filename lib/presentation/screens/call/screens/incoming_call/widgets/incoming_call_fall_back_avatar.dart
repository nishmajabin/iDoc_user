import 'package:flutter/material.dart';

class IncomingCallFallBackAvatar extends StatelessWidget {
  final String doctorName;

  const IncomingCallFallBackAvatar({required this.doctorName, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF37474F),
      child: Center(
        child: Text(
          doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}