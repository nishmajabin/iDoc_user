import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_app_bar_background.dart';

class EditProfileAppBar extends StatelessWidget {
  const EditProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF052C40),
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        background: const EditProfileAppBarBackground(),
        collapseMode: CollapseMode.pin,
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}