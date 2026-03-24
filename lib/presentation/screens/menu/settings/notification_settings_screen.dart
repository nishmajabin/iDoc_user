import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/logic/blocs/settings/settings_event.dart';
import 'package:idoc_user/logic/blocs/settings/settings_state.dart';
import 'package:idoc_user/presentation/screens/menu/settings/sub_header.dart';

class NotificationSettingsScreen extends StatelessWidget {
  final String userId;
  const NotificationSettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            SettingsSubHeader(title: 'Notification Settings', subtitle: 'Manage your alert preferences'),
            Expanded(
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (state is! SettingsLoaded) {
                    return const Center(
                      child: Text('Unable to load settings.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  final s = state.settings;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Info banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline_rounded,
                                color: AppColors.primary, size: 17),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Changes are saved automatically and synced across your devices.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.primary,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _SectionLabel('Channels'),
                      _NotifCard(children: [
                        _Toggle(
                          icon: Icons.notifications_active_rounded,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primarySurface,
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts on your device',
                          value: s.pushNotificationsEnabled,
                          onChanged: (v) => context.read<SettingsBloc>()
                              .add(ToggleNotifications(enabled: v)),
                        ),
                        _divider,
                        _Toggle(
                          icon: Icons.email_rounded,
                          iconColor: AppColors.completed,
                          iconBg: AppColors.completedSurface,
                          title: 'Email Notifications',
                          subtitle: 'Summaries sent to your inbox',
                          value: s.emailNotificationsEnabled,
                          onChanged: (v) => context.read<SettingsBloc>()
                              .add(ToggleEmailNotifications(enabled: v)),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      _SectionLabel('Alert Types'),
                      _NotifCard(children: [
                        _Toggle(
                          icon: Icons.alarm_rounded,
                          iconColor: AppColors.pending,
                          iconBg: AppColors.pendingSurface,
                          title: 'Appointment Reminders',
                          subtitle: 'Reminded 10 min before appointments',
                          value: s.appointmentRemindersEnabled,
                          onChanged: (v) => context.read<SettingsBloc>()
                              .add(ToggleAppointmentReminders(enabled: v)),
                        ),
                        _divider,
                        _Toggle(
                          icon: Icons.chat_bubble_rounded,
                          iconColor: AppColors.accent,
                          iconBg: AppColors.primarySurface,
                          title: 'Chat Messages',
                          subtitle: 'Alerts for new messages from doctors',
                          value: s.chatNotificationsEnabled,
                          onChanged: (v) => context.read<SettingsBloc>()
                              .add(ToggleChatNotifications(enabled: v)),
                        ),
                      ]),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _divider = Divider(
      height: 1, indent: 64, endIndent: 16, color: AppColors.divider);
}

// ── Notification card container ───────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final List<Widget> children;
  const _NotifCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(children: children),
        ),
      );
}

// ── Toggle row ────────────────────────────────────────────────────────────────

class _Toggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Reusable helpers ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      );
}