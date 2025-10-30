import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showImageSourceDialog({
  required BuildContext context,
  required VoidCallback onCameraSelected,
  required VoidCallback onGallerySelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Profile Photo',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF6AD2FF)),
            title: Text(
              'Take Photo',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            onTap: onCameraSelected,
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF6AD2FF)),
            title: Text(
              'Choose from Gallery',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            onTap: onGallerySelected,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}