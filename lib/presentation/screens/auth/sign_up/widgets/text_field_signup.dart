import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/core/constants/color.dart';

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
  final String? labelText;
  final bool obscureText;
  final VoidCallback? onSuffixTap;

  const CustomTextInputField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.autoValidateMode,
    this.labelText,
    this.validator,
    this.backgroundColor = const Color(0xFFF7FAFF),
    this.borderColor = const Color(0xFF052C40),
    this.borderWidth = 1.5,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixTap,
    this.addShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          addShadow
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    offset: const Offset(3, 4),
                  ),
                ],
              )
              : null,
      child: TextFormField(
        autovalidateMode: autoValidateMode,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 62, 62, 62),
            fontWeight: FontWeight.w400,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF052C40), fontSize: 16),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF052C40)),
          suffixIcon:
              isPassword
                  ? InkWell(
                    onTap: onSuffixTap,
                    child: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primaryColor,
                    ),
                  )
                  : null,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(
              color: AppColors.primaryColor.withValues(alpha: 0.6),
              width: borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(
              color: AppColors.primaryColor.withValues(alpha: 0.6),
              width: borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(
              color: AppColors.primaryColor.withValues(alpha: 0.6),
              width: borderWidth,
            ),
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
