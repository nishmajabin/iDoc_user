import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:second_project/presentation/screens/home/widgets/category_card.dart';
import 'package:second_project/presentation/screens/home/widgets/custom_carousel.dart';
import 'package:second_project/presentation/screens/home/widgets/doctors_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE6EFF9),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SafeArea(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Find Your',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          35,
                                          35,
                                          35,
                                        ),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      'Specialist',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          48,
                                          48,
                                          48,
                                        ),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        CupertinoIcons.search,
                                        size: 28,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Symbols.sms_rounded,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 190,
                      left: 0,
                      right: 0,
                      child: buildCarousel([]),
                    ),
                  ],
                ),
                const SizedBox(height: 120),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Categories Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildCategoryCard(
                        'assets/images/medicine.png',
                        'Pediatrician',
                      ),
                      buildCategoryCard(
                        'assets/images/brain.png',
                        'Neurosurgeon',
                      ),
                      buildCategoryCard(
                        'assets/images/healthcare.png',
                        'Cardiologist',
                      ),
                      buildCategoryCard(
                        'assets/images/psych.png',
                        'Psychiatrist',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Available Doctor Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Doctor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                buildDoctorsList([]),
              ],
            ),
          ),
        );
      },
    );
  }
}
