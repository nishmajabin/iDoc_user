import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FeaturedDoctorCardImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String heroTag;

  const FeaturedDoctorCardImage({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: (imageUrl?.isNotEmpty ?? false)
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _ImagePlaceholder(),
                errorWidget: (_, __, ___) => _FallbackAvatar(name: name),
              )
            : _FallbackAvatar(name: name),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        color: const Color(0xFFB3DAF1).withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90D9)),
          ),
        ),
      );
}

class _FallbackAvatar extends StatelessWidget {
  final String name;
  const _FallbackAvatar({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        color: const Color(0xFFC8DFEE),
        child: Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF4A90D9).withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'D',
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