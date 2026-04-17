import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class UserChatLoadingView extends StatelessWidget {
  const UserChatLoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
}