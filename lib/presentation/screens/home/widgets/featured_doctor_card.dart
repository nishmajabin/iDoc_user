import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_card_blobs.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_doctor_card_image.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_doctor_info.dart';

class FeaturedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const FeaturedDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDetailScreen(doctorId: doctor.id!),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background gradient
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD5EFFF), Color(0xFFB3DAF1), Color(0xFF8EC5E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Decorative blobs
              const SizedBox(height: 180, child: FeaturedCardBlobs()),

              // Content
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(flex: 3, child: FeaturedDoctorInfo(doctor: doctor)),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FeaturedDoctorCardImage(
                          imageUrl: doctor.profileImageUrl,
                          name: doctor.name,
                          heroTag: 'doctor_carousel_${doctor.id}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
