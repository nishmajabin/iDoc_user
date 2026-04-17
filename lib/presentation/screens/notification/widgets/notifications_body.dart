import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_bloc.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_state.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_empty_or_error.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_list.dart';

class NotificationsBody extends StatelessWidget {
  final String userId;

  const NotificationsBody({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationHistoryBloc, NotificationHistoryState>(
      builder: (context, state) {
        if (state is NotificationHistoryLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is NotificationHistoryError) {
          return NotificationsEmptyOrError(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: state.message,
          );
        }

        if (state is NotificationHistoryLoaded) {
          if (state.notifications.isEmpty) {
            return const NotificationsEmptyOrError(
              icon: Icons.notifications_off_rounded,
              title: 'No notifications yet',
              subtitle:
                  'You\'ll see appointment confirmations,\n'
                  'chat messages, calls, and reminders here.',
            );
          }

          return NotificationList(
            notifications: state.notifications,
            userId: userId,
          );
        }

        // Initial / unknown state.
        return const NotificationsEmptyOrError(
          icon: Icons.notifications_off_rounded,
          title: 'No notifications yet',
          subtitle:
              'You\'ll see appointment confirmations,\n'
              'chat messages, calls, and reminders here.',
        );
      },
    );
  }
}
