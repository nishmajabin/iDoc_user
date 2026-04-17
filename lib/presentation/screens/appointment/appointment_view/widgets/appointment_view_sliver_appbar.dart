import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

class AppointmentViewSliverAppBar extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentViewSliverAppBar({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: AppColors.gradientStart,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme:  IconThemeData(color: AppColors.backgroundColor),
      title:  Text(
        'Appointment Details',
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
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
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor.withValues(alpha: 0.18),
                          border: Border.all(
                            color: AppColors.backgroundColor.withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                          image: (appointment.doctorProfileImageUrl != null &&
                                  appointment.doctorProfileImageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(
                                    appointment.doctorProfileImageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (appointment.doctorProfileImageUrl == null ||
                                appointment.doctorProfileImageUrl!.isEmpty)
                            ?  Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.backgroundColor,
                                  size: 36,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dr. ${appointment.doctorName ?? 'Doctor'}',
                        style:  TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (appointment.doctorSpecialist != null &&
                          appointment.doctorSpecialist!.isNotEmpty) ...[
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
                            appointment.doctorSpecialist!,
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