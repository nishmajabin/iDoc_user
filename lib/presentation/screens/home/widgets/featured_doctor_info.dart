import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_rating_badge.dart';

class FeaturedDoctorInfo extends StatelessWidget {
  final DoctorModel doctor;
  const FeaturedDoctorInfo({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Looking For Your Desire\nSpecialist Doctor?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E40),
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            doctor.specialist,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4E7A93),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            doctor.place,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF4E7A93).withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FeaturedRatingBadge(
            averageRating: doctor.averageRating,
            totalRatings: doctor.totalRatings,
          ),
        ],
      ),
    );
  }
}