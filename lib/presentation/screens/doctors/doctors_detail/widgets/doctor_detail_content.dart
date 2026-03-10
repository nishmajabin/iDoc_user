import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/book_appointment_button.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_about_section.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_contact_section.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_header.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_info_section.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_license_section.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_rating_section.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_display.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_consultation_fee_section.dart';

class DoctorDetailContent extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetailContent({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        DoctorHeader(doctor: doctor),
        SliverToBoxAdapter(
          child: _DoctorDetailsBody(doctor: doctor),
        ),
      ],
    );
  }
}

class _DoctorDetailsBody extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorDetailsBody({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorNameAndSpecialty(doctor: doctor),
            const SizedBox(height: 24),
            DoctorInfoSection(doctor: doctor),
            const SizedBox(height: 20),
            DoctorConsultationFeeSection(doctor: doctor), // ← CONSULTATION FEE
            const SizedBox(height: 24),
            DoctorRatingSection(doctor: doctor),
            const SizedBox(height: 32),
            DoctorAboutSection(bio: doctor.bio),
            const SizedBox(height: 32),
            DoctorContactSection(doctor: doctor),
            const SizedBox(height: 32),
            DoctorLicenseSection(licenseNumber: doctor.licenseNumber),
            const SizedBox(height: 32),
            BookAppointmentButton(
              doctorId: doctor.id ?? '',
              doctorName: doctor.name,
              doctorSpecialist: doctor.specialist,
              doctorProfileImageUrl: doctor.profileImageUrl,
              consultationFee: doctor.consultationFee, // ← PASS FEE
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DoctorNameAndSpecialty extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorNameAndSpecialty({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialist,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        RatingDisplay(
          rating: doctor.averageRating,
          totalRatings: doctor.totalRatings,
          size: 18,
        ),
      ],
    );
  }
}