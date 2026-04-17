import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_list_card.dart';

Widget buildDoctorsListVertical(List<DoctorModel> doctors) {
  if (doctors.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_information,
                size: 50,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 10),
              Text(
                'No Doctors Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Doctors will appear here once approved',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show only first 6 doctors in home screen
  final displayDoctors = doctors.take(6).toList();

  return SizedBox(
    height: 340, // Reduced height to prevent overflow
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: (displayDoctors.length / 2).ceil(), // Number of columns needed
      itemBuilder: (context, columnIndex) {
        final startIndex = columnIndex * 2;
        final endIndex = (startIndex + 2).clamp(0, displayDoctors.length);
        final columnDoctors = displayDoctors.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(
            right:
                columnIndex < (displayDoctors.length / 2).ceil() - 1 ? 12 : 0,
          ),
          child: Column(
            children: [
              // First card in column
              buildDoctorCard(columnDoctors[0]),

              // Second card in column (if exists)
              if (columnDoctors.length > 1) ...[
                const SizedBox(height: 10),
                buildDoctorCard(columnDoctors[1]),
              ],
            ],
          ),
        );
      },
    ),
  );
}
