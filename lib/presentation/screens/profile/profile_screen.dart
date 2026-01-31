import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_event.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/presentation/screens/profile/widgets/profile_screen_body.dart';
import 'package:idoc_user/presentation/screens/profile/widgets/profile_screen_listener.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: ProfileScreenListener(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileInitial) {
              context.read<ProfileBloc>().add(const FetchUserProfile());
            }    
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return _buildLoadingIndicator();
    }

    final profileData = _extractProfileData(state);

    if (profileData != null) {
      final isUploading = state is ProfileImageUploading;
      final uploadProgress = isUploading ? state.progress : 0.0;

      return ProfileScreenBody(
        profileData: profileData,
        isUploading: isUploading,
        uploadProgress: uploadProgress,
        imagePickerService: ImagePickerService(),
      );
    }

    if (state is ProfileFailure) {
      return Center(child: Text(state.error));
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
        strokeWidth: 1.5,
      ),
    );
  }

  ProfileSuccess? _extractProfileData(ProfileState state) {
    if (state is ProfileSuccess) {
      return state;
    } else if (state is ProfileImageUploading) {
      return state.currentProfile;
    }
    return null;
  }
}