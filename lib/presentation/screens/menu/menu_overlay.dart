import 'package:flutter/material.dart';

class MenuOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const MenuOverlay({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose, // Tap outside to close
      child: Container(
        color: Colors.black.withValues(alpha: 0.3), // Semi-transparent background
        child: GestureDetector(
          onTap: () {}, // Prevent tap from closing when tapping menu
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.calendar_today,
                        label: 'My Appointment',
                        onTap: () {
                          onClose();
                          // Navigate to appointments
                          // Navigator.pushNamed(context, '/appointments');
                        },
                      ),
                      const Divider(height: 1, color: Colors.white54),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () {
                          onClose();
                          // Navigate to profile detail
                          // Navigator.pushNamed(context, '/profile-detail');
                        },
                      ),
                      const Divider(height: 1, color: Colors.white54),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.settings,
                        label: 'Settings',
                        onTap: () {
                          onClose();
                          // Navigate to settings
                          // Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      const Divider(height: 1, color: Colors.white54),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.logout,
                        label: 'Log Out',
                        onTap: () {
                          onClose();
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout logic
              // Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}