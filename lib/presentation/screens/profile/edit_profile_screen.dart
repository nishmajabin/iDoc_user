import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_event.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/presentation/screens/profile/widgets/image_source_dialog.dart';
import 'package:idoc_user/presentation/screens/profile/widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileSuccess profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profileData.name);
    _phoneController =
        TextEditingController(text: widget.profileData.mobileNumber ?? '');
    _addressController =
        TextEditingController(text: widget.profileData.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          setState(() => _isSaving = false);
          Navigator.pop(context);
        } else if (state is ProfileLoading) {
          setState(() => _isSaving = true);
        } else if (state is ProfileFailure) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 16),
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
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F8FF),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final currentProfile = _extractProfile(state);
            final isUploading = state is ProfileImageUploading;
            final uploadProgress =
                isUploading ? (state as ProfileImageUploading).progress : 0.0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatarSection(
                            context,
                            currentProfile,
                            isUploading,
                            uploadProgress,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionLabel('Personal Information'),
                          const SizedBox(height: 14),
                          _buildCard(
                            children: [
                              _buildField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'Enter your name',
                                icon: Icons.person_outline_rounded,
                                iconColor: const Color(0xFF0096C7),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  if (v.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Contact Details'),
                          const SizedBox(height: 14),
                          _buildCard(
                            children: [
                              _buildField(
                                controller: _phoneController,
                                label: 'Mobile Number',
                                hint: '+1 234 567 8900',
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF2D9E6B),
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v != null &&
                                      v.isNotEmpty &&
                                      v.length < 7) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              Divider(
                                height: 1,
                                color: const Color(0xFFEEF2F7),
                                indent: 56,
                                endIndent: 20,
                              ),
                              _buildField(
                                controller: _addressController,
                                label: 'Address',
                                hint: 'Your full address',
                                icon: Icons.location_on_outlined,
                                iconColor: const Color(0xFF2D9E6B),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),
                          _buildSaveButton(context),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF052C40),
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackground(),
        collapseMode: CollapseMode.pin,
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
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
        ),
      ),
    );
  }

  Widget _buildAppBarBackground() {
    return Container(
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
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    ProfileSuccess? profile,
    bool isUploading,
    double uploadProgress,
  ) {
    return Center(
      child: Column(
        children: [
          ProfileAvatarWidget(
            imageUrl: profile?.profileImageUrl ??
                widget.profileData.profileImageUrl,
            isUploading: isUploading,
            uploadProgress: uploadProgress,
            onEditPressed: () => _handleAvatarEdit(context),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _handleAvatarEdit(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: Color(0xFF0096C7),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Change Photo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0096C7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052C40).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A2332),
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9DAFC2),
                  letterSpacing: 0.4,
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBDC8D5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                errorStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD13D3D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: _isSaving ? null : () => _handleSave(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSaving
                ? [const Color(0xFF9DAFC2), const Color(0xFFADB8C9)]
                : [const Color(0xFF052C40), const Color(0xFF0A4A6B)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isSaving
              ? []
              : [
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
            if (_isSaving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              _isSaving ? 'Saving...' : 'Save Changes',
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

  void _handleSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            UpdateUserProfile(
              name: _nameController.text.trim(),
              mobileNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              address: _addressController.text.trim(),
            ),
          );
    }
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
    final image = await _imagePickerService.pickImageFromCamera();
    if (image != null && context.mounted) {
      context.read<ProfileBloc>().add(UpdateProfileImage(imageFile: image));
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final image = await _imagePickerService.pickImageFromGallery();
    if (image != null && context.mounted) {
      context.read<ProfileBloc>().add(UpdateProfileImage(imageFile: image));
    }
  }

  ProfileSuccess? _extractProfile(ProfileState state) {
    if (state is ProfileSuccess) return state;
    if (state is ProfileImageUploading) return state.currentProfile;
    if (state is ProfileUpdateSuccess) return state.profile;
    return null;
  }
}