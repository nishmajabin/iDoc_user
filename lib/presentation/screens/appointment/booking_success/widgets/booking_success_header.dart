import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessHeader extends StatelessWidget {
  const BookingSuccessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'BOOKING SUCCESSFUL!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your appointment has been confirmed',
          style: TextStyle(fontSize: 16, color: AppColors.lightTextColor),
        ),
      ],
    );
  }
}