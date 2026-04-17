import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AddPatientDoctorCard extends StatelessWidget {
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
 
  const AddPatientDoctorCard({
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    super.key
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              image: doctorProfileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(doctorProfileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: doctorProfileImageUrl == null
                ? const Icon(Icons.person, size: 30, color: AppColors.disabledIconColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${doctorName ?? "Doctor"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctorSpecialist ?? 'Specialist',
                  style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorBgColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppColors.errorBgColor, size: 20),
          ),
        ],
      ),
    );
  }
}