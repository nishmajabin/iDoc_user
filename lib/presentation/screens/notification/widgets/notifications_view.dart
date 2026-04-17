import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/notification/notification_bloc.dart';
import 'package:idoc_user/logic/blocs/notification/notification_state.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_bloc.dart';
import 'package:idoc_user/logic/blocs/notification_history/notification_history_event.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_cubit.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_state.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_body.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_header.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  // ── User-id helper ────────────────────────────────────────────────────────

  String? _userId(BuildContext context) {
    final state = context.read<NotificationBloc>().state;
    return state is NotificationReady ? state.userId : null;
  }

  // ── Lifecycle: load on first build ────────────────────────────────────────

  void _loadNotifications(BuildContext context) {
    final notifState = context.read<NotificationBloc>().state;
    if (notifState is NotificationReady) {
      context
          .read<NotificationHistoryBloc>()
          .add(LoadNotificationHistory(userId: notifState.userId));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) _loadNotifications(context);
    });

    return BlocListener<NotificationsScreenCubit, NotificationsScreenState>(
      listener: _handleSideEffects,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: AppColors.gradientStart,
          body: Column(
            children: [
              NotificationsHeader(userId: _userId(context)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.bgBase,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: NotificationsBody(userId: _userId(context) ?? ''),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Side-effect handler ───────────────────────────────────────────────────

  void _handleSideEffects(
      BuildContext context, NotificationsScreenState state) {
    if (state is NotificationsScreenShowClearDialog) {
      _showClearAllDialog(context, state.userId);
      context.read<NotificationsScreenCubit>().dialogHandled();
    } else if (state is NotificationsScreenNavigate) {
      _handleNavigation(context, state);
      context.read<NotificationsScreenCubit>().navigationHandled();
    }
  }

  void _showClearAllDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationHistoryBloc>().add(
                    ClearAllNotifications(userId: userId),
                  );
              Navigator.pop(ctx);
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.cancelled),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(
      BuildContext context, NotificationsScreenNavigate state) {
    switch (state.target) {
      case NotificationNavTarget.appointment:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening appointment details…'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case NotificationNavTarget.chat:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening chat…'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case NotificationNavTarget.videoCall:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening video call…'),
            backgroundColor: AppColors.videocall,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }
}