import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_event.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:second_project/presentation/bottom%20nav/bottom_nav.dart';
import 'package:second_project/presentation/screens/available%20specialists/available_specialists.dart';
import 'package:second_project/presentation/screens/home/home_screen.dart';
import 'package:second_project/presentation/screens/notification/notification_screen.dart';
import 'package:second_project/presentation/screens/profile/profile_screen.dart';

class BottomScreen extends StatelessWidget {
  const BottomScreen({super.key});

  @override
  Widget build(BuildContext context) {
   return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE6EFF9),
          body: _buildBody(state.currentIndex),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<BottomNavBloc>().add(BottomNavTabChanged(index));
            },
          ),
        );
      },
    );
  }

 Widget _buildBody(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AvailableSpecialists();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }


}