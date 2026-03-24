import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_event.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_state.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/my_appointment_screen.dart';
import 'package:idoc_user/presentation/screens/menu/settings/settings_screen.dart';
import 'package:idoc_user/presentation/screens/menu/widgets/logout_dialog.dart';
import 'package:idoc_user/presentation/screens/menu/widgets/menu_divider.dart';
import 'package:idoc_user/presentation/screens/menu/widgets/menu_item.dart';
import 'package:idoc_user/presentation/screens/profile/profile_screen.dart';

class MenuPanel extends StatelessWidget {
  final VoidCallback onClose;

  const MenuPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          onClose();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
            (route) => false,
          );
        } else if (state is LogoutFailure) {
          log('Logout failed: ${state.error}');
          onClose();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: _buildDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuItem(
              icon: Icons.calendar_today,
              label: 'My Appointment',
              onTap: () {
                onClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAppointmentsScreen(),
                  ),
                );
              },
            ),
            const MenuDivider(),
            MenuItem(
              icon: Icons.person,
              label: 'Profile',
              onTap: () {
                onClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const MenuDivider(),
            MenuItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                onClose();
                final user = FirebaseAuth.instance.currentUser;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => SettingsBloc(),
                      child: SettingsScreen(
                        userId: user?.uid ?? '',
                        userName: user?.displayName ?? 'User',
                        userEmail: user?.email ?? '',
                        userAvatarUrl: user?.photoURL,
                      ),
                    ),
                  ),
                );
              },
            ),
            const MenuDivider(),
            BlocBuilder<LogoutBloc, LogoutState>(
              builder: (context, state) {
                final isLoading = state is LogoutLoading;

                return MenuItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  isLoading: isLoading,
                  onTap: isLoading
                      ? () => log('Logout already in progress')
                      : () {
                          log('Opening logout dialog');
                          showLogoutDialog(
                            context: context,
                            onConfirm: () {
                              log('Logout confirmed - Triggering LogoutRequested event');
                              context
                                  .read<LogoutBloc>()
                                  .add(const LogoutRequested());
                            },
                          );
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: const Color(0xFFB3E5FC),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}