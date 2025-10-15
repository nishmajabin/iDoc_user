import 'package:flutter/material.dart';

Widget customImageContainer({required String imagePath}) {
  const double imageSize = 290;
  return Center(
    child: Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.medical_services,
                size: 45,
                color: Colors.blue[800],
              ),
            );
          },
        ),
      ),
    ),
  );
}
