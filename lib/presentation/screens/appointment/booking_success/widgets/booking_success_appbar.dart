import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class BookingSuccessAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BookingSuccessAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Booking Confirmed'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.backgroundColor,
      foregroundColor: AppColors.shadowDark,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}