import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/categories/all_categories/all_categories_screen.dart';
import 'package:idoc_user/presentation/screens/home/widgets/categories_grid_home.dart';
import 'package:idoc_user/presentation/widgets/section_header.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Categories',
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllCategoriesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        const CategoriesGridHome(),
      ],
    );
  }
}
