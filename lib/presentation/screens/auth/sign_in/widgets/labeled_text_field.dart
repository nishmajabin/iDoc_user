import 'package:flutter/material.dart';
import 'package:second_project/presentation/widgets/text_form_field.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color borderColor;
  final Color? backgroundColor;
  final double? borderWidth;
  final TextInputType? keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.borderColor = Colors.transparent,
    this.backgroundColor,
    this.borderWidth,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052C40),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextInputField(
          controller: controller,
          hintText: hintText,
          prefixIcon: prefixIcon,
          borderColor: borderColor,
          backgroundColor: backgroundColor ?? Colors.white,
          keyboardType: keyboardType ?? TextInputType.text,
          isPassword: isPassword,
          validator: validator,
        ),
      ],
    );
  }
}