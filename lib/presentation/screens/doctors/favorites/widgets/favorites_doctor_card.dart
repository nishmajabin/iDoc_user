import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_doctor_avatar.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_heart_button.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_info_chip.dart';

class FavoritesDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const FavoritesDoctorCard({required this.doctor, super.key});

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
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF052C40).withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ────────────────────────────────────────────────────
              FavoritesDoctorAvatar(
                imageUrl: doctor.profileImageUrl,
                name: doctor.name,
              ),
              const SizedBox(width: 14),

              // ── Info ──────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${doctor.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                doctor.specialist,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Each card gets its own isolated HeartButtonCubit
                        FavoritesHeartButton(doctor: doctor),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Chips ─────────────────────────────────────────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (doctor.totalRatings > 0)
                          FavoritesInfoChip(
                            icon: Icons.star_rounded,
                            label:
                                '${doctor.averageRating.toStringAsFixed(1)} (${doctor.totalRatings})',
                            iconColor: const Color(0xFFF5A623),
                            bgColor: const Color(0xFFFFF8EC),
                          ),
                        FavoritesInfoChip(
                          icon: Icons.work_history_rounded,
                          label: '${doctor.experience} yrs exp',
                          iconColor: AppColors.confirmed,
                          bgColor: AppColors.confirmedSurface,
                        ),
                        if (doctor.consultationFee != null)
                          FavoritesInfoChip(
                            icon: Icons.currency_rupee_rounded,
                            label:
                                '₹${doctor.consultationFee!.toStringAsFixed(0)}',
                            iconColor: AppColors.completed,
                            bgColor: AppColors.completedSurface,
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Book now ──────────────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DoctorDetailScreen(doctorId: doctor.id!),
                        ),
                      ),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Book Appointment',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
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