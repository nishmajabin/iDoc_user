import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_initials_fall_back.dart';

class FavoritesDoctorAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;

  const FavoritesDoctorAvatar({required this.imageUrl, required this.name, super.key});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 82,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.confirmed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    FavoritesInitialsFallBack(initials: _initials),
                errorWidget: (_, __, ___) =>
                    FavoritesInitialsFallBack(initials: _initials),
              )
            : FavoritesInitialsFallBack(initials: _initials),
      ),
    );
  }
}