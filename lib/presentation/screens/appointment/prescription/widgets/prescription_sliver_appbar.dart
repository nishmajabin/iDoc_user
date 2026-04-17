import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/prescription_model.dart';

class PrescriptionSliverAppbar extends StatelessWidget {
  final UserPrescriptionRecord record;
  const PrescriptionSliverAppbar({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return 
    SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: AppColors.gradientStart,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.backgroundColor),

      //  Title ONLY here — renders only when bar is fully collapsed
      title:  Text(
        'Prescription',
        style: TextStyle(
          color: AppColors.backgroundColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,

      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative circles ────────────────────────────────────
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundColor.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundColor.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // ── Doctor info — below status bar + back button ──────────
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Extra top offset to clear the back button row
                      const SizedBox(height: 32),

                      // Doctor avatar
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor.withValues(alpha: 0.18),
                          border: Border.all(
                            color: AppColors.backgroundColor.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                          image:
                              (record.doctorProfileImageUrl != null &&
                                      record.doctorProfileImageUrl!.isNotEmpty)
                                  ? DecorationImage(
                                    image: NetworkImage(
                                      record.doctorProfileImageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            (record.doctorProfileImageUrl == null ||
                                    record.doctorProfileImageUrl!.isEmpty)
                                ? Center(
                                  child: Text(
                                    record.doctorName != null &&
                                            record.doctorName!.isNotEmpty
                                        ? record.doctorName![0].toUpperCase()
                                        : 'D',
                                    style: TextStyle(
                                      color: AppColors.backgroundColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(height: 12),

                      // Doctor name
                      Text(
                        record.doctorName != null
                            ? 'Dr. ${record.doctorName}'
                            : 'Doctor',
                        style: TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      // Specialist
                      if (record.doctorSpecialist != null &&
                          record.doctorSpecialist!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            record.doctorSpecialist!,
                            style: TextStyle(
                              color: AppColors.backgroundColor.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
