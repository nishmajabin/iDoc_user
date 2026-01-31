import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

class DoctorGridCard extends StatelessWidget {
  final dynamic doctor;

  const DoctorGridCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorImage(imageUrl: doctor.profileImageUrl),
            _DoctorInfo(doctor: doctor),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(doctorId: doctor.id!),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _DoctorImage extends StatelessWidget {
  final String? imageUrl;

  const _DoctorImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholderWidget(),
        errorWidget: (context, url, error) => _errorWidget(),
      ),
    );
  }

  Widget _placeholderWidget() {
    return Container(
      height: 140,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      height: 140,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  final dynamic doctor;

  const _DoctorInfo({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoctorName(name: doctor.name),
          const SizedBox(height: 4),
          _DoctorSpecialist(specialist: doctor.specialist),
          const SizedBox(height: 8),
          _DoctorExperience(experience: doctor.experience),
        ],
      ),
    );
  }
}

class _DoctorName extends StatelessWidget {
  final String name;

  const _DoctorName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DoctorSpecialist extends StatelessWidget {
  final String specialist;

  const _DoctorSpecialist({required this.specialist});

  @override
  Widget build(BuildContext context) {
    return Text(
      specialist,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }
}

class _DoctorExperience extends StatelessWidget {
  final int experience;

  const _DoctorExperience({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.work_outline, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '$experience years',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}