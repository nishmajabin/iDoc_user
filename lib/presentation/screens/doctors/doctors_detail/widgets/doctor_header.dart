import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_model.dart';

class DoctorHeader extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorHeader({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: _BackButton(),
      flexibleSpace: FlexibleSpaceBar(
        background: _DoctorProfileImage(imageUrl: doctor.profileImageUrl),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }
}

class _DoctorProfileImage extends StatelessWidget {
  final String? imageUrl;

  const _DoctorProfileImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.person, size: 100, color: Colors.grey),
      ),
    );
  }
}