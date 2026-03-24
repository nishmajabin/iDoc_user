import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

class FeaturedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const FeaturedDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailScreen(doctorId: doctor.id!),
          ),
        );
      },
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
              // ── Background gradient ──
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD5EFFF),
                      Color(0xFFB3DAF1),
                      Color(0xFF8EC5E6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // ── Decorative blobs ──
              Positioned(
                top: -25,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7AB8DB).withValues(alpha: 0.25),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 100,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF94CEE8).withValues(alpha: 0.20),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 100,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 60,
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: const Color(0xFF5BA0C8).withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                top: 50,
                left: 170,
                child: Icon(
                  Icons.add,
                  size: 12,
                  color: const Color(0xFF5BA0C8).withValues(alpha: 0.4),
                ),
              ),

              // ── Content ──
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    // Left: Text content
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 8, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Looking For Your Desire',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                                height: 1.3,
                              ),
                            ),
                            const Text(
                              'Specialist Doctor?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Doctor name
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

                            // Specialization
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

                            // Clinic / Place
                            Text(
                              doctor.place,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4E7A93).withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 6),

                            // Rating badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFFFC107),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    doctor.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${doctor.totalRatings})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color(0xFF2C3E50)
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right: Doctor image
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: _buildDoctorImage(),
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

  Widget _buildDoctorImage() {
    return Hero(
      tag: 'doctor_carousel_${doctor.id}',
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: doctor.profileImageUrl != null &&
                doctor.profileImageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: doctor.profileImageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: const Color(0xFFB3DAF1).withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A90D9),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackAvatar(),
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      height: 180,
      color: const Color(0xFFC8DFEE),
      child: Center(
        child: CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF4A90D9).withValues(alpha: 0.2),
          child: Text(
            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90D9),
            ),
          ),
        ),
      ),
    );
  }
}
