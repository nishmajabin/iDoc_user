import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_grid_card.dart';

class SpecialistsGridView extends StatelessWidget {
  final List<dynamic> doctors;

  const SpecialistsGridView({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.75,
      ),
      itemCount: doctors.length,
      itemBuilder:
          (context, index) => SpecialistsGridCard(doctor: doctors[index]),
    );
  }
}
