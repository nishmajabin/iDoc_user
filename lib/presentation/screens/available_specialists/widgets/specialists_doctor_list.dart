import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_grid_view.dart';

class SpecialistsDoctorList extends StatelessWidget {
  const SpecialistsDoctorList({required this.doctors, super.key});

  final List<DoctorModel> doctors;

  String get _resultLabel {
    final count = doctors.length;
    return '$count doctor${count != 1 ? 's' : ''} found';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results count banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.backgroundColor,
          child: Text(
            _resultLabel,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Doctor grid
        Expanded(child: SpecialistsGridView(doctors: doctors)),
      ],
    );
  }
}