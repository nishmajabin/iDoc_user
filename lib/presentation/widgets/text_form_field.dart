
import 'package:flutter/material.dart';

Widget buildTextInputField({
  required String hintText,
  required IconData prefixIcon,
  required TextEditingController controller,
  String? Function(String?)? validator,
  Color backgroundColor = Colors.white,
  Color borderColor = const Color(0xFF052C40),
  double borderWidth = 1.5,
  TextInputType keyboardType = TextInputType.text,
  bool isPassword = false,
  bool addShadow = false, 
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(50.0), // Rounded pill shape
      border: Border.all(
        color: borderColor, // Light border
        width: borderWidth,
      ),
      boxShadow: addShadow 
      ? [
        BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.15), offset: Offset(0, 4)),
      ]
      : [],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 16),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF052C40)),
        suffixIcon:
            isPassword
                ? Icon(Icons.remove_red_eye_outlined, color: Color(0xFF555555))
                : Text(''),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 10.0,
        ),
      ),
      validator: validator,
    ),
  );
}
