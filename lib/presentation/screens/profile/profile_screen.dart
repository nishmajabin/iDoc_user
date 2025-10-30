import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/data/services/image_picker.dart';
import 'package:second_project/logic/blocs/profile/profile_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_screen_body.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_screen_listener.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ImagePickerService _imagePickerService;

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    // Fetch profile when screen loads
    context.read<ProfileBloc>().add(const FetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: ProfileScreenListener(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) => _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading) {
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
        imagePickerService: _imagePickerService,
      );
    }

    if (state is ProfileFailure) {
      return Center(child: Text(state.error));
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
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