import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/cubits/edit_profile/edit_profile_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/image_source_dialog.dart';

mixin EditProfileHandlers {
  GlobalKey<FormState> get formKey;
  TextEditingController get nameController;
  TextEditingController get phoneController;
  TextEditingController get addressController;
  ImagePickerService get imagePickerService;

  /// Validates the form then delegates to [EditProfileCubit.saveProfile].
  void handleSave(BuildContext context) {
    if (!(formKey.currentState?.validate() ?? false)) return;

    context.read<EditProfileCubit>().saveProfile(
          name: nameController.text,
          phone: phoneController.text,
          address: addressController.text,
        );
  }

  /// Shows the image-source bottom sheet and routes to camera or gallery.
  void handleAvatarEdit(BuildContext context) {
    showImageSourceDialog(
      context: context,
      onCameraSelected: () {
        Navigator.pop(context);
        _pickImageFromCamera(context);
      },
      onGallerySelected: () {
        Navigator.pop(context);
        _pickImageFromGallery(context);
      },
    );
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final image = await imagePickerService.pickImageFromCamera();
    if (image != null && context.mounted) {
      context.read<EditProfileCubit>().updateProfileImage(image);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final image = await imagePickerService.pickImageFromGallery();
    if (image != null && context.mounted) {
      context.read<EditProfileCubit>().updateProfileImage(image);
    }
  }
}