import 'package:flutter/material.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';

ProfileSuccess? extractProfile(ProfileState state) {
  if (state is ProfileSuccess) return state;
  if (state is ProfileImageUploading) return state.currentProfile;
  if (state is ProfileUpdateSuccess) return state.profile;
  return null;
}

SnackBar buildErrorSnackBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: const Color(0xFFD13D3D),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  );
}