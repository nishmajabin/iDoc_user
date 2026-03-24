import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/user_model.dart';
import 'package:idoc_user/presentation/screens/home/widgets/categories_section.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctors_section.dart';
import 'package:idoc_user/presentation/screens/home/widgets/home_header.dart';

class HomeBodySection extends StatelessWidget {
  final UserModel user;
  const HomeBodySection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(user: user),
          const SizedBox(height: 120),
          const HomeCategoriesSection(),
          const SizedBox(height: 15),
          const HomeDoctorsSection(),
        ],
      ),
    );
  }
}
