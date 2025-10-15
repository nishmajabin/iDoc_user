import 'package:flutter/material.dart';
import 'package:second_project/presentation/screens/get%20started%20screens/get_started_screen2.dart';
import 'package:second_project/presentation/screens/get%20started%20screens/welcome_screen.dart';
import 'package:second_project/presentation/screens/get%20started%20screens/widgets/custom_container.dart';

class GetStartedScreen1 extends StatelessWidget {
  const GetStartedScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: customContainer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
        
                      Container(
                        width: double.infinity,
                        height: 337,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8D4D1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/medical_team.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8D4D1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.medical_services,
                                    size: 45,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 40),
        
                      const Text(
                        'Striving to improve community health\ncare and practices',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF052C40),
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
        
                      const SizedBox(height: 32),
        
                      const Text(
                        'IMPROVE YOUR LIFESTYLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF052C40),
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Color.fromARGB(156, 5, 44, 64),
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.all(24.0),
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
                          color: Color.fromARGB(255, 121, 121, 121),
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
                              builder: (context) => GetStartedScreen2(),
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
  }
}
