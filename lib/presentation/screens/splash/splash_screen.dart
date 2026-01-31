import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_bloc.dart';
import 'package:idoc_user/logic/blocs/splash/splash_state.dart';
import 'package:idoc_user/presentation/bottom_nav/bottom_screen.dart';
import 'package:idoc_user/presentation/screens/get_started_screens/get_started_screen1.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            // Check if user is authenticated
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              // User is logged in, go to Home
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => BottomScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GetStartedScreen1()),
              );
            }
          }
        },
        builder: (context, state) {
          double scale = 1.0;
          if (state is SplashAnimating) {
            scale = state.scale;
          }
          return Center(
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: 250,
                height: 250,
                child: Image.asset(
                  'assets/images/idoc_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
