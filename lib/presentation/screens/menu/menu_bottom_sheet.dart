import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_event.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_state.dart';
import 'package:second_project/presentation/screens/menu/widgets/logout_dialog.dart';
import 'package:second_project/presentation/screens/menu/widgets/menu_item.dart';
import 'package:second_project/presentation/screens/profile/profile_screen.dart';

class MenuPanel extends StatelessWidget {
  final VoidCallback onClose;

  const MenuPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: _buildDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuItem(
            icon: Icons.calendar_today,
            label: 'My Appointment',
            onTap: () => onClose(),
          ),
          const MenuDivider(),
          MenuItem(
            icon: Icons.person,
            label: 'Profile',
            onTap: () {
              onClose();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const MenuDivider(),
          MenuItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () => onClose(),
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
                            context.read<LogoutBloc>().add(const LogoutRequested());
                          },
                        );
                      },
              );
            },
          ),
        ],
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

class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Colors.white54,
      indent: 16,
      endIndent: 16,
    );
  }
}