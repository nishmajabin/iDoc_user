import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class SignUpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignUpButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.shadowDark,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: const BorderSide(color: AppColors.signInBorder, width: 5),
          ),
          disabledBackgroundColor: AppColors.disabledIconColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child:
              isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundColor),
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    'NEXT',
                    style: GoogleFonts.poppins(
                      color: AppColors.backgroundColor,
                      fontSize: 17.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }
}
