import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';

class RegisterLink extends StatelessWidget {
  final VoidCallback onTap;

  const RegisterLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
          children: [
            TextSpan(
              text: 'Register now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.logRegLinkColor,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}