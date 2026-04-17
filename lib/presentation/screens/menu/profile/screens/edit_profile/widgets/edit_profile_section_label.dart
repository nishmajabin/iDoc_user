import 'package:flutter/material.dart';

class EditProfileSectionLabel extends StatelessWidget {
  final String label;
  const EditProfileSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9DAFC2),
        letterSpacing: 1.2,
      ),
    );
  }
}