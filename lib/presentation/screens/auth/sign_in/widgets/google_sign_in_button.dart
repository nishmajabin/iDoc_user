import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDisabled;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Image.asset('assets/images/google.png', height: 24),
      label:  Text(
        'Sign up with Google',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.signUpText,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        side:  BorderSide(
          color: AppColors.signUpBorder,
          width: 0.8,
        ),
      ),
    );
  }
}