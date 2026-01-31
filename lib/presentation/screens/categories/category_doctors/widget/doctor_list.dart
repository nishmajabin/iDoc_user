import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/categories/category_doctors/widget/doctor_list_card.dart';

class DoctorList extends StatelessWidget {
  final List<dynamic> doctors;

  const DoctorList({
    super.key,
    required this.doctors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return DoctorListCard(doctor: doctors[index]);
      },
    );
  }
}