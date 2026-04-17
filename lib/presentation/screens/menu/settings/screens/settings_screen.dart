import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_state.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/logic/blocs/settings/settings_event.dart';
import 'package:idoc_user/logic/blocs/settings/settings_state.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_card.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_logout_button.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_profile_card.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_section_header.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/settings_sliver_app_bar.dart';
import 'package:idoc_user/presentation/screens/menu/settings/widgets/tile_data.dart';
import 'about_app/screen/about_app_screen.dart';
import 'help_support/screen/help_support_screen.dart';
import 'notification_settings/screen/notification_settings_screen.dart';
import 'privacy_policy/privacy_policy_screen.dart';
import 'terms_conditions/terms_conditions_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    context.read<SettingsBloc>().add(LoadSettings(userId: userId));

    return MultiBlocListener(
      listeners: [
        // Settings errors (toggle save failures)
        BlocListener<SettingsBloc, SettingsState>(
          listener: (ctx, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.cancelled,
              ));
            }
          },
        ),
        // Logout result
        BlocListener<LogoutBloc, LogoutState>(
          listener: (ctx, state) {
            if (state is LogoutSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            }
            if (state is LogoutFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.cancelled,
              ));
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light
            .copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.bgBase,
          // AnimatedOpacity replaces FadeTransition + AnimationController.
          // It self-animates from 0→1 on first build with no vsync or State.
          body: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SettingsSliverAppBar(userId: userId),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsProfileCard(
                          userName: userName,
                          userEmail: userEmail,
                          avatarUrl: userAvatarUrl,
                        ),
                        const SizedBox(height: 28),

                        // ── Preferences ──────────────────────────────────
                        const SettingsSectionHeader('Preferences'),
                        SettingsCard(items: [
                          TileData(
                            icon: Icons.notifications_rounded,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.primarySurface,
                            label: 'Notification Settings',
                            subtitle: 'Push, email & reminder preferences',
                            onTap: () => _push(
                              context,
                              NotificationSettingsScreen(userId: userId),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Legal ─────────────────────────────────────────
                        const SettingsSectionHeader('Legal'),
                        SettingsCard(items: [
                          TileData(
                            icon: Icons.shield_rounded,
                            iconColor: AppColors.completed,
                            iconBg: AppColors.completedSurface,
                            label: 'Privacy Policy',
                            subtitle: 'How we handle your data',
                            onTap: () =>
                                _push(context, const PrivacyPolicyScreen()),
                          ),
                          TileData(
                            icon: Icons.description_rounded,
                            iconColor: AppColors.accent,
                            iconBg: AppColors.primarySurface,
                            label: 'Terms & Conditions',
                            subtitle: 'Usage rules and agreements',
                            onTap: () =>
                                _push(context, const TermsConditionsScreen()),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Support ───────────────────────────────────────
                        const SettingsSectionHeader('Support'),
                        SettingsCard(items: [
                          TileData(
                            icon: Icons.headset_mic_rounded,
                            iconColor: AppColors.pending,
                            iconBg: AppColors.pendingSurface,
                            label: 'Help & Support',
                            subtitle: 'FAQs and contact options',
                            onTap: () =>
                                _push(context, const HelpSupportScreen()),
                          ),
                          TileData(
                            icon: Icons.info_rounded,
                            iconColor: AppColors.confirmed,
                            iconBg: AppColors.confirmedSurface,
                            label: 'About App',
                            subtitle: 'Version, licenses & more',
                            onTap: () =>
                                _push(context, const AboutAppScreen()),
                          ),
                        ]),

                        const SizedBox(height: 32),
                        const SettingsLogoutButton(),
                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            'iDoc  •  v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
