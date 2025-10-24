import 'package:flutter/material.dart';
import 'package:second_project/presentation/screens/home/widgets/doctor_profile_card.dart';

Widget buildDoctorsList(List doctors) {
  if (doctors.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              SizedBox(height: 10),
              Text(
                'No Doctors Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 5),
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

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children:
          doctors.map((doctor) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: buildDoctorProfileCard(
                  doctor['name'],
                  doctor['specialty'],
                  doctor['experience'],
                  doctor['patients'],
                  doctor['imageUrl'],
                ),
              ),
            );
          }).toList(),
    ),
  );
}
