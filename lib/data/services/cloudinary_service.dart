import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      'dwykvyw5l',
      'profile_images_preset',
      cache: false,
    );
  }

  Future<String> uploadImage(File imageFile) async {

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        imageFile.path,
        folder: 'profile_images',
        resourceType: CloudinaryResourceType.Image,
      ),
    );

    final downloadUrl = response.secureUrl;

    return downloadUrl;
  }
}