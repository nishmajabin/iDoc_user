import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_event.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/screens/edit_profile_screen.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/profile_screen_body.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => SignInScreen()),
            (route) => false,
          );
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.error)),
                ],
              ),
              backgroundColor: const Color(0xFFD13D3D),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text('Profile updated successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF2D9E6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial) {
            context.read<ProfileBloc>().add(const FetchUserProfile());
          }

          if (state is ProfileLoading || state is ProfileInitial) {
            return const _LoadingScreen();
          }

          final profileData = _extractProfileData(state);

          if (profileData != null) {
            final isUploading = state is ProfileImageUploading;
            final uploadProgress = isUploading ? (state as ProfileImageUploading).progress : 0.0;

            return ProfileBody(
              profileData: profileData,
              isUploading: isUploading,
              uploadProgress: uploadProgress,
              imagePickerService: ImagePickerService(),
              onEditPressed: () => _navigateToEdit(context, profileData),
              onLogout: () => context.read<ProfileBloc>().add(const LogoutRequested()),
            );
          }

          if (state is ProfileFailure) {
            return _ErrorScreen(error: state.error);
          }

          return const _ErrorScreen(error: 'Something went wrong');
        },
      ),
    );
  }

  ProfileSuccess? _extractProfileData(ProfileState state) {
    if (state is ProfileSuccess) return state;
    if (state is ProfileImageUploading) return state.currentProfile;
    if (state is ProfileUpdateSuccess) return state.profile;
    return null;
  }

  void _navigateToEdit(BuildContext context, ProfileSuccess profileData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfileScreen(profileData: profileData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: const Color(0xFF00B4D8),
                strokeWidth: 2.5,
                backgroundColor: const Color(0xFF00B4D8).withOpacity(0.15),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading profile...',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7A91),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  size: 40,
                  color: Color(0xFFD13D3D),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7A91),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () =>
                    context.read<ProfileBloc>().add(const FetchUserProfile()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF00B4D8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}