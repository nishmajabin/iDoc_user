import 'package:flutter/material.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_info_field.dart';

class ProfileInfoSection extends StatelessWidget {
  final ProfileSuccess profileData;

  const ProfileInfoSection({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileInfoField(
            label: 'Name',
            value: profileData.name,
          ),
          const SizedBox(height: 20),
          ProfileInfoField(
            label: 'Email',
            value: profileData.email,
          ),
          const SizedBox(height: 20),
          ProfileInfoField(
            label: 'Mobile Number',
            value: profileData.mobileNumber ?? 'Not provided',
            isPlaceholder: profileData.mobileNumber == null,
          ),
          const SizedBox(height: 20),
          ProfileInfoField(
            label: 'Address',
            value: profileData.address.isNotEmpty
                ? profileData.address
                : 'Not provided',
            isPlaceholder: profileData.address.isEmpty,
          ),
        ],
      ),
    );
  }
}