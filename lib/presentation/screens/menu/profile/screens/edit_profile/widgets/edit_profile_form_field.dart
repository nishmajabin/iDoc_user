import 'package:flutter/material.dart';

class EditProfileFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const EditProfileFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A2332),
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9DAFC2),
                  letterSpacing: 0.4,
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBDC8D5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                errorStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD13D3D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}