import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_event.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:second_project/presentation/bottom_nav/bottom_nav.dart';
import 'package:second_project/presentation/screens/available_specialists/available_specialists_screen.dart';
import 'package:second_project/presentation/screens/home/home_screen.dart';
import 'package:second_project/presentation/screens/menu/menu_overlay.dart';
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
          body: Stack(
            children: [
              // Show the actual screen content
              IndexedStack(
                index: state.currentIndex == 3 
                    ? state.previousIndex 
                    : state.currentIndex,
                children: const [
                  HomeScreen(),
                  AvailableSpecialists(),
                  NotificationsScreen(),
                  ProfileScreen(),
                ],
              ),
              // Show menu overlay when index is 3
              if (state.currentIndex == 3)
                MenuOverlay(
                  onClose: () {
                    context.read<BottomNavBloc>().add(
                      BottomNavTabChanged(state.previousIndex),
                    );
                  },
                ),
            ],
          ),
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
}