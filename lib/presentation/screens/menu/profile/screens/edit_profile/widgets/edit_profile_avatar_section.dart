import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/profile_avatar.dart';

class EditProfileAvatarSection extends StatelessWidget {
  final String? imageUrl;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onEditPressed;

  const EditProfileAvatarSection({
    required this.imageUrl,
    required this.isUploading,
    required this.uploadProgress,
    required this.onEditPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileAvatarWidget(
            imageUrl: imageUrl,
            isUploading: isUploading,
            uploadProgress: uploadProgress,
            onEditPressed: onEditPressed,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: Color(0xFF0096C7),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Change Photo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0096C7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}