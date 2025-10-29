import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_state.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_event.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:second_project/presentation/bottom_nav/bottom_nav.dart';
import 'package:second_project/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:second_project/presentation/screens/available_specialists/available_specialists_screen.dart';
import 'package:second_project/presentation/screens/home/home_screen.dart';
import 'package:second_project/presentation/screens/menu/menu_bottom_sheet.dart';
import 'package:second_project/presentation/screens/notification/notification_screen.dart';
import 'package:second_project/presentation/screens/profile/profile_screen.dart';

class BottomScreen extends StatelessWidget {
  const BottomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          final bottomNavBloc = context.read<BottomNavBloc>();
          final currentIndex = bottomNavBloc.state.currentIndex;

          if (currentIndex == 3) {
            final previousIndex = bottomNavBloc.state.previousIndex;
            bottomNavBloc.add(BottomNavTabChanged(previousIndex));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          try {
            bottomNavBloc.add(const BottomNavReset());
          } catch (e) {
            throw Exception('BottomNavBloc reset error: $e');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            }
          });
        } else if (state is LogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFE6EFF9),
            body: Stack(
              children: [
                _buildBody(
                  state.currentIndex == 3
                      ? state.previousIndex
                      : state.currentIndex,
                ),

                if (state.currentIndex == 3)
                  GestureDetector(
                    onTap: () {
                      context.read<BottomNavBloc>().add(
                        BottomNavTabChanged(state.previousIndex),
                      );
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),

                if (state.currentIndex == 3)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: MenuPanel(
                      onClose: () {
                        context.read<BottomNavBloc>().add(
                          BottomNavTabChanged(state.previousIndex),
                        );
                      },
                    ),
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
      ),
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
