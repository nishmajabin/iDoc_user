import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class PrescriptionDoctorAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const PrescriptionDoctorAvatar({required this.name, this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gradientColor.withValues(alpha: 0.2),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(
            color: AppColors.cardBg.withValues(alpha: 0.45), width: 2),
      ),
      child: hasImage
          ? null
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color:AppColors.cardBg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}