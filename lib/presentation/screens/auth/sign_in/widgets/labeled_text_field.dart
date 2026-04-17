import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
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

  const LabeledTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.label,
    this.autoValidateMode,
    this.labelText,
    this.validator,
    this.backgroundColor = AppColors.backgroundColor,
    this.borderColor = AppColors.transparentColor,
    this.borderWidth = 0.9,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixTap,
    this.addShadow = false,
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
        Container(
          decoration:
              addShadow
                  ? BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: AppColors.shadowDark.withValues(alpha: 0.25),
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
                color: AppColors.lightTextColor2,
                fontWeight: FontWeight.w400,
              ),
              hintText: hintText,
              hintStyle:  TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
              ),
              prefixIcon: Icon(prefixIcon, color: AppColors.primaryColor),
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
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
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
        ),
      ],
    );
  }
}
