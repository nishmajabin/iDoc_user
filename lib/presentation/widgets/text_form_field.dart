import 'package:flutter/material.dart';

class CustomTextInputField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final TextInputType keyboardType;
  final AutovalidateMode? autoValidateMode;
  final bool isPassword;
  final bool addShadow;

  const CustomTextInputField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.autoValidateMode,
    this.validator,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFF052C40),
    this.borderWidth = 1.5,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.addShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: addShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(3, 4),
                ),
              ],
            )
          : null,
      child: TextFormField(
        autovalidateMode: autoValidateMode,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF052C40),
            fontSize: 16,
          ),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF052C40)),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 10.0,
          ),
        ),
        validator: validator,
      ),
    );
  }
}