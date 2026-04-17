// lib/presentation/screens/profile/widgets/profile_info_section.dart

import 'package:flutter/material.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';

class ProfileInfoSection extends StatelessWidget {
  final ProfileSuccess profileData;

  const ProfileInfoSection({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Full Name',
                  value: profileData.name,
                  iconColor: const Color(0xFF4A90D9),
                  isFirst: true,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: profileData.email,
                  iconColor: const Color(0xFF7C3AED),
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: profileData.mobileNumber ?? 'Not provided',
                  iconColor: const Color(0xFF059669),
                  isPlaceholder: profileData.mobileNumber == null,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: profileData.address.isNotEmpty
                      ? profileData.address
                      : 'Not provided',
                  iconColor: const Color(0xFFD97706),
                  isPlaceholder: profileData.address.isEmpty,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isPlaceholder = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPlaceholder
                        ? Colors.grey[400]
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 76,
    );
  }
}