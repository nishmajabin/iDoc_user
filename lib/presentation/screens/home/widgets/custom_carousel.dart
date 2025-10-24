import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:second_project/presentation/screens/home/widgets/doctors_card.dart';

Widget buildCarousel(List doctors) {
  if (doctors.isEmpty) {
    return Container(
      height: 180,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/carousel_background.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 50, color: Colors.white70),
            SizedBox(height: 10),
            Text(
              'No Featured Doctors Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'Check back soon!',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  return CarouselSlider(
    options: CarouselOptions(
      height: 180,
      enlargeCenterPage: true,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 3),
      aspectRatio: 2.0,
      viewportFraction: 0.85,
    ),
    items:
        doctors.map((doctor) {
          return buildDoctorCard(
            doctor['name'],
            doctor['specialty'],
            doctor['clinic'],
            doctor['backgroundImage'],
          );
        }).toList(),
  );
}
