import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

class SpecialistsGridCard extends StatelessWidget {
  final dynamic doctor;

  const SpecialistsGridCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetailScreen(doctorId: doctor.id!),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // ── Use a Column where image is Expanded, info is fixed ──────────────
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildDoctorImage()),
            _buildDoctorInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: CachedNetworkImage(
        imageUrl: doctor.profileImageUrl ?? '',
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.confirmedSurface,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.backgroundColor,
          child: const Center(
            child: Icon(Icons.person_rounded, size: 44, color: AppColors.primaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Dr. ${doctor.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.confirmedSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              doctor.specialist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}