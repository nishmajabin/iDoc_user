import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_event.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/image_source_dialog.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/profile_avatar.dart';
import 'package:idoc_user/presentation/screens/menu/profile/widgets/profile_info_field.dart';

const double _avatarTotalRadius = 59.0;

class ProfileBody extends StatelessWidget {
  final ProfileSuccess profileData;
  final bool isUploading;
  final double uploadProgress;
  final ImagePickerService imagePickerService;
  final VoidCallback onEditPressed;
  final VoidCallback onLogout;

  const ProfileBody({
    super.key,
    required this.profileData,
    required this.isUploading,
    required this.uploadProgress,
    required this.imagePickerService,
    required this.onEditPressed,
    required this.onLogout,
  });

  static const double _headerHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FF),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Space for header + avatar overlap
                SizedBox(height: topPadding + _headerHeight + _avatarTotalRadius),
                const SizedBox(height: 12),
                _buildNameSection(),
                const SizedBox(height: 28),
                _buildInfoCards(),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 48),
              ],
            ),
          ),
          // Fixed header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context, topPadding),
          ),
          // Avatar overlapping header bottom
          Positioned(
            top: topPadding + _headerHeight - _avatarTotalRadius,
            left: 0,
            right: 0,
            child: Center(
              child: ProfileAvatarWidget(
                imageUrl: profileData.profileImageUrl,
                isUploading: isUploading,
                uploadProgress: uploadProgress,
                onEditPressed: () => _handleAvatarEdit(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Container(
      height: topPadding + _headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF052C40),
            Color(0xFF0A4A6B),
            Color(0xFF0096C7),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4D8).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6AD2FF).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Nav row
          Positioned(
            top: topPadding + 4,
            left: 8,
            right: 8,
            child: Row(
              children: [
                _buildBackButton(context),
                const Spacer(),
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                _buildEditAction(),
              ],
            ),
          ),
          // Subtitle above avatar
          Positioned(
            bottom: _avatarTotalRadius + 16,
            left: 0,
            right: 0,
            child: Text(
              'Manage your personal information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.65),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildEditAction() {
    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 14),
            SizedBox(width: 5),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      children: [
        Text(
          profileData.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2332),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F4FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_outlined, size: 13, color: Color(0xFF0096C7)),
              SizedBox(width: 5),
              Text(
                'Verified Patient',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0096C7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Personal Information'),
          const SizedBox(height: 12),
          ProfileInfoCard(
            fields: [
              ProfileInfoField(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                value: profileData.name,
                iconColor: const Color(0xFF0096C7),
              ),
              ProfileInfoField(
                icon: Icons.mail_outline_rounded,
                label: 'Email Address',
                value: profileData.email,
                iconColor: const Color(0xFF0096C7),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Contact Details'),
          const SizedBox(height: 12),
          ProfileInfoCard(
            fields: [
              ProfileInfoField(
                icon: Icons.phone_outlined,
                label: 'Mobile Number',
                value: profileData.mobileNumber ?? 'Not provided',
                isPlaceholder: profileData.mobileNumber == null,
                iconColor: const Color(0xFF2D9E6B),
              ),
              ProfileInfoField(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: profileData.address.isNotEmpty ? profileData.address : 'Not provided',
                isPlaceholder: profileData.address.isEmpty,
                iconColor: const Color(0xFF2D9E6B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9DAFC2),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildPrimaryButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            onTap: onEditPressed,
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'Sign Out',
            icon: Icons.logout_rounded,
            color: const Color(0xFFD13D3D),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF052C40), Color(0xFF0A4A6B)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF052C40).withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFD13D3D), size: 28),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sign Out?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A2332)),
              ),
              const SizedBox(height: 10),
              const Text(
                'You will be signed out of your account. You can sign back in anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7A91), height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7A91), fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        onLogout();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD13D3D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}