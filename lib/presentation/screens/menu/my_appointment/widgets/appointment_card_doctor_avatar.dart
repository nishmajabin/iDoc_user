import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AppointmentCardDoctorAvatar extends StatelessWidget {
  final String? imageUrl, name;
  const AppointmentCardDoctorAvatar({this.imageUrl, this.name, super.key});
 
  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          image: (imageUrl?.isNotEmpty ?? false)
              ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: (imageUrl?.isNotEmpty ?? false)
            ? null
            : Center(
                child: Text(
                  name?.isNotEmpty == true ? name![0].toUpperCase() : 'D',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
      );
}
 