import 'package:flutter/material.dart';
import 'package:second_project/presentation/screens/get_started_screens/get_started_screen4.dart';
import 'package:second_project/presentation/screens/get_started_screens/welcome_screen.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/custom_container.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/custom_image_container.dart';
import 'package:second_project/presentation/screens/get_started_screens/widgets/positioned_container.dart';

class GetStartedScreen3 extends StatelessWidget {
  const GetStartedScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: customContainer(
        child: Stack(
          children: [
            positionedRight(),
            LayoutBuilder(
              builder: (context, constraints) {
                final contentHeight = constraints.maxHeight;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: contentHeight),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: screenHeight * 0.08),
                              customImageContainer(
                                imagePath: 'assets/images/doctor_check.jpg',
                              ),
                              SizedBox(height: screenHeight * 0.08),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Text(
                                  'Choose Best Doctors',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF052C40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Text(
                                  'Your health is our priority. Connect with top-rated specialists and board-certified physicians dedicated to providing personalized, high-quality care',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF677294),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 15.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => WelcomeScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF052C40),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF052C40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => GetStartedScreen4(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF6AD2FF),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
