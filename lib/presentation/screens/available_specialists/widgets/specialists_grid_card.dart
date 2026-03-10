import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

class SpecialistsGridCard extends StatelessWidget {
  final dynamic doctor;

  const SpecialistsGridCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctorId: doctor.id!),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 251, 253, 255),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildDoctorImage(), _buildDoctorInfo()],
        ),
      ),
    );
  }

  Widget _buildDoctorImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: CachedNetworkImage(
        imageUrl: doctor.profileImageUrl ?? '',
        width: double.infinity,
        height: 110,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              height: 140,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 140,
              color: Colors.grey[200],
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Center(
        child: Column(
          children: [
            Text(
              doctor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            Text(
              doctor.specialist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
