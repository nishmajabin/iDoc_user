import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';

class DoctorAboutSection extends StatelessWidget {
  final String bio;

  const DoctorAboutSection({
    super.key,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'About'),
        const SizedBox(height: 12),
        Text(
          bio,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}