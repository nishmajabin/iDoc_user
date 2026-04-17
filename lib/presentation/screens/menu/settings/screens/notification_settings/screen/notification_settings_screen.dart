import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/logic/blocs/settings/settings_event.dart';
import 'package:idoc_user/logic/blocs/settings/settings_state.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/notification_settings/widgets/notification_settings_card.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/notification_settings/widgets/notification_settings_section_label.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/notification_settings/widgets/notification_settings_toggle.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/notification_settings/widgets/settings_sub_header.dart';

class NotificationSettingsScreen extends StatelessWidget {
  final String userId;
  const NotificationSettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    context.read<SettingsBloc>().add(LoadSettings(userId: userId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            SettingsSubHeader(
              title: 'Notification Settings',
              subtitle: 'Manage your alert preferences',
            ),
            Expanded(
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoading || state is SettingsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }
                  if (state is SettingsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (state is! SettingsLoaded) {
                    return const Center(
                      child: Text(
                        'Unable to load settings.',
                        style:
                            TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final s = state.settings;
                  return ListView(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 40),
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
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        child: const Row(
                          children: [
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

                      const NotificationSettingsSectionLabel('Channels'),
                      NotificationSettingsCard(children: [
                        NotificationSettingsToggle(
                          icon: Icons.notifications_active_rounded,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primarySurface,
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts on your device',
                          value: s.pushNotificationsEnabled,
                          onChanged: (v) => context
                              .read<SettingsBloc>()
                              .add(ToggleNotifications(enabled: v)),
                        ),
                        _divider,
                        NotificationSettingsToggle(
                          icon: Icons.email_rounded,
                          iconColor: AppColors.completed,
                          iconBg: AppColors.completedSurface,
                          title: 'Email Notifications',
                          subtitle: 'Summaries sent to your inbox',
                          value: s.emailNotificationsEnabled,
                          onChanged: (v) => context
                              .read<SettingsBloc>()
                              .add(ToggleEmailNotifications(enabled: v)),
                        ),
                      ]),

                      const SizedBox(height: 20),
                      const NotificationSettingsSectionLabel('Alert Types'),
                      NotificationSettingsCard(children: [
                        NotificationSettingsToggle(
                          icon: Icons.alarm_rounded,
                          iconColor: AppColors.pending,
                          iconBg: AppColors.pendingSurface,
                          title: 'Appointment Reminders',
                          subtitle: 'Reminded 10 min before appointments',
                          value: s.appointmentRemindersEnabled,
                          onChanged: (v) => context
                              .read<SettingsBloc>()
                              .add(ToggleAppointmentReminders(enabled: v)),
                        ),
                        _divider,
                        NotificationSettingsToggle(
                          icon: Icons.chat_bubble_rounded,
                          iconColor: AppColors.accent,
                          iconBg: AppColors.primarySurface,
                          title: 'Chat Messages',
                          subtitle: 'Alerts for new messages from doctors',
                          value: s.chatNotificationsEnabled,
                          onChanged: (v) => context
                              .read<SettingsBloc>()
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
      height: 1,
      indent: 64,
      endIndent: 16,
      color: AppColors.divider);
}
