import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/notifications/notifications_screen_cubit.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_view.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsScreenCubit(),
      child: const NotificationsView(),
    );
  }
}
