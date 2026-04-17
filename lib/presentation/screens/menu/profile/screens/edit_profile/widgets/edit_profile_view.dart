import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/image_picker.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/logic/cubits/edit_profile/edit_profile_cubit.dart';
import 'package:idoc_user/logic/cubits/edit_profile/edit_profile_cubit_state.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_app_bar.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_avatar_section.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_form_card.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_form_field.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_handlers.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_helpers.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_save_button.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_section_label.dart';

class EditProfileView extends StatelessWidget with EditProfileHandlers {
  final ProfileSuccess profileData;
 
  @override
  final TextEditingController nameController;
  @override
  final TextEditingController phoneController;
  @override
  final TextEditingController addressController;
  @override
  final GlobalKey<FormState> formKey;
  @override
  final ImagePickerService imagePickerService;
 
  EditProfileView({super.key, required this.profileData})
      : nameController = TextEditingController(text: profileData.name),
        phoneController =
            TextEditingController(text: profileData.mobileNumber ?? ''),
        addressController =
            TextEditingController(text: profileData.address),
        formKey = GlobalKey<FormState>(),
        imagePickerService = ImagePickerService();
 
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Bridge: forward ProfileBloc emissions into EditProfileCubit.
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, profileState) => context
              .read<EditProfileCubit>()
              .onProfileBlocStateChanged(profileState),
        ),
        // React to local cubit states: navigate or show SnackBar.
        BlocListener<EditProfileCubit, EditProfileScreenState>(
          listener: (context, state) {
            if (state is EditProfileSaveSuccess) {
              Navigator.pop(context);
            } else if (state is EditProfileSaveFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(buildErrorSnackBar(state.message));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F8FF),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final currentProfile = extractProfile(profileState);
            final isUploading = profileState is ProfileImageUploading;
            final uploadProgress = isUploading
                ? (profileState as ProfileImageUploading).progress
                : 0.0;
 
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const EditProfileAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditProfileAvatarSection(
                            imageUrl: currentProfile?.profileImageUrl ??
                                profileData.profileImageUrl,
                            isUploading: isUploading,
                            uploadProgress: uploadProgress,
                            onEditPressed: () => handleAvatarEdit(context),
                          ),
                          const SizedBox(height: 32),
                          const EditProfileSectionLabel('Personal Information'),
                          const SizedBox(height: 14),
                          EditProfileFormCard(
                            children: [
                              EditProfileFormField(
                                controller: nameController,
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
                          const EditProfileSectionLabel('Contact Details'),
                          const SizedBox(height: 14),
                          EditProfileFormCard(
                            children: [
                              EditProfileFormField(
                                controller: phoneController,
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
                              const Divider(
                                height: 1,
                                color: Color(0xFFEEF2F7),
                                indent: 56,
                                endIndent: 20,
                              ),
                              EditProfileFormField(
                                controller: addressController,
                                label: 'Address',
                                hint: 'Your full address',
                                icon: Icons.location_on_outlined,
                                iconColor: const Color(0xFF2D9E6B),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),
                          // Only rebuilds when saving state toggles.
                          BlocBuilder<EditProfileCubit, EditProfileScreenState>(
                            buildWhen: (prev, curr) =>
                                (prev is EditProfileSaving) !=
                                (curr is EditProfileSaving),
                            builder: (context, state) => EditProfileSaveButton(
                              isSaving: state is EditProfileSaving,
                              onTap: () => handleSave(context),
                            ),
                          ),
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
}