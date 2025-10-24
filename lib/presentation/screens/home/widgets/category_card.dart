import 'package:flutter/material.dart';

Widget buildCategoryCard(String imagePath, String label) {
  return Container(
    width: 90,
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
