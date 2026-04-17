import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';

class DoctorContactSection extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorContactSection({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Contact Information'),
        const SizedBox(height: 16),
        ContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: doctor.phone,
        ),
        const SizedBox(height: 12),
        ContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: doctor.email,
        ),
      ],
    );
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ContactItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFF9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ContactIconContainer(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: _ContactInfo(label: label, value: value),
          ),
        ],
      ),
    );
  }
}

class _ContactIconContainer extends StatelessWidget {
  final IconData icon;

  const _ContactIconContainer({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primaryColor, size: 24),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ContactInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
