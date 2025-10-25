import 'package:flutter/material.dart';
import 'package:second_project/presentation/widgets/text_form_field.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextInputField(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      borderColor: Colors.transparent,
      keyboardType: keyboardType,
      addShadow: true,
      validator: validator,
    );
  }
}
