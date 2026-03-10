import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/doctors/all_doctors/all_doctors_screen.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctors_list_home.dart';
import 'package:idoc_user/presentation/widgets/section_header.dart';

class HomeDoctorsSection extends StatelessWidget {
  const HomeDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Available Doctors',

          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllDoctorsScreen()),
            );
          },
        ),
        const SizedBox(height: 15),
        const DoctorsListHome(),
      ],
    );
  }
}
