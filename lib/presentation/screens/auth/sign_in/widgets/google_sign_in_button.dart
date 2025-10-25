import 'package:flutter/material.dart';

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
      label: const Text(
        'Sign up with Google',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        side: const BorderSide(
          color: Color(0xFF052C40),
          width: 0.8,
        ),
      ),
    );
  }
}