import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_event.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_state.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogoutBloc, LogoutState>(
      builder: (ctx, state) {
        final busy = state is LogoutLoading;
        return GestureDetector(
          onTap: busy ? null : () => _confirmLogout(ctx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.cancelled.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.cancelled.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.cancelled),
                  )
                else
                  const Icon(Icons.logout_rounded,
                      color: AppColors.cancelled, size: 20),
                const SizedBox(width: 10),
                Text(
                  busy ? 'Logging out…' : 'Log Out',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cancelled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cancelled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.cancelled, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LogoutBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cancelled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}