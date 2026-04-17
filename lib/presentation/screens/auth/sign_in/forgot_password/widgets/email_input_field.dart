import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const EmailInputField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.backBtnIconColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                color: AppColors.lightTextColor.withValues(alpha: 0.5),
                fontSize: 15,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.email_outlined,
                  color: AppColors.lightTextColor,
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}