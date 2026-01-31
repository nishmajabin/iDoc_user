import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_contact_section.dart';

class DoctorLicenseSection extends StatelessWidget {
  final String licenseNumber;

  const DoctorLicenseSection({
    super.key,
    required this.licenseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'License Information'),
        const SizedBox(height: 16),
        ContactItem(
          icon: Icons.badge_outlined,
          label: 'License Number',
          value: licenseNumber,
        ),
      ],
    );
  }
}