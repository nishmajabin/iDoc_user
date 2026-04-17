import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/widgets/medical_chat_sheet_tile.dart';

class MedicalChatImageSourceSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const MedicalChatImageSourceSheet(
      {required this.onGallery, required this.onCamera, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attach Medical Image',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload a photo for AI medical analysis',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          MedicalChatSheetTile(
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            onTap: onGallery,
          ),
          const SizedBox(height: 10),
          MedicalChatSheetTile(
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            onTap: onCamera,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
