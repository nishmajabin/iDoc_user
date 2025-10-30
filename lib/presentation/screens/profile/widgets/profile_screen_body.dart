import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/data/services/image_picker.dart';
import 'package:second_project/logic/blocs/profile/profile_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_header.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_avatar.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_info_section.dart';
import 'package:second_project/presentation/screens/profile/widgets/image_source_dialog.dart';

class ProfileScreenBody extends StatelessWidget {
  final ProfileSuccess profileData;
  final bool isUploading;
  final double uploadProgress;
  final ImagePickerService imagePickerService;

  const ProfileScreenBody({
    super.key,
    required this.profileData,
    required this.isUploading,
    required this.uploadProgress,
    required this.imagePickerService,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildScrollableContent(),
        _buildHeader(context),
        _buildAvatar(context),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 250),
          ProfileInfoSection(profileData: profileData),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ProfileHeader(
      onBackPressed: () => Navigator.pop(context),
      onEditPressed: () {
        //  navigate to edit page when it is clicked
        
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return ProfileAvatar(
      imageUrl: profileData.profileImageUrl,
      topPosition: MediaQuery.of(context).padding.top + 90,
      isUploading: isUploading,
      uploadProgress: uploadProgress,
      onEditPressed: () => _handleAvatarEdit(context),
    );
  }

  void _handleAvatarEdit(BuildContext context) {
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
      context.read<ProfileBloc>().add(UpdateProfileImage(imageFile: image));
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final image = await imagePickerService.pickImageFromGallery();
    if (image != null && context.mounted) {
      context.read<ProfileBloc>().add(UpdateProfileImage(imageFile: image));
    }
  }
}
