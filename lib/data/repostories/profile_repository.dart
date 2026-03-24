import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idoc_user/data/services/cloudinary_service.dart';
import 'package:idoc_user/data/services/profile_firestore_service.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';

class ProfileRepository {
  final ProfileFirestoreService _firestoreService;
  final CloudinaryService _cloudinaryService;
  final FirebaseAuth _auth;

  ProfileRepository({
    ProfileFirestoreService? firestoreService,
    CloudinaryService? cloudinaryService,
    FirebaseAuth? auth,
  })  : _firestoreService = firestoreService ?? ProfileFirestoreService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _auth = auth ?? FirebaseAuth.instance;

  Future<ProfileSuccess> fetchUserProfile() async {
    final userData = await _firestoreService.getUserProfile();
    return _mapToProfileSuccess(userData);
  }

  Future<ProfileSuccess> updateUserProfile({
    required String name,
    String? mobileNumber,
    required String address,
    String? currentImageUrl,
  }) async {
    await _firestoreService.updateUserProfile(
      name: name,
      mobileNumber: mobileNumber,
      address: address,
    );

    final user = await _firestoreService.getCurrentUser();

    return ProfileSuccess(
      name: name,
      email: user['email'] as String,
      mobileNumber: mobileNumber,
      address: address,
      profileImageUrl: currentImageUrl,
    );
  }

  Future<ProfileSuccess> updateProfileImage({
    required File imageFile,
    ProfileSuccess? currentProfile,
    required Function(double) onProgress,
  }) async {
    onProgress(0.0);
    final imageUrl = await _cloudinaryService.uploadImage(imageFile);
    onProgress(1.0);

    await _firestoreService.updateProfileImage(imageUrl);

    if (currentProfile != null) {
      return currentProfile.copyWith(profileImageUrl: imageUrl);
    }

    final userData = await _firestoreService.getUserProfile();
    return _mapToProfileSuccess(userData).copyWith(profileImageUrl: imageUrl);
  }

  Future<ProfileSuccess?> getCurrentProfile(ProfileState currentState) async {
    if (currentState is ProfileSuccess) {
      return currentState;
    }

    try {
      final userData = await _firestoreService.getUserProfile();
      return _mapToProfileSuccess(userData);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  ProfileSuccess _mapToProfileSuccess(Map<String, dynamic> data) {
    return ProfileSuccess(
      name: data['name'] as String,
      email: data['email'] as String,
      mobileNumber: data['mobileNumber'] as String?,
      address: data['address'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
}