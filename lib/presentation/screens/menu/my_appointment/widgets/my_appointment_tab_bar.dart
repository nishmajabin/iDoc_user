import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/my_appointment/appointment_tab_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_tab_item.dart';

class MyAppointmentTabBar extends StatelessWidget {
  const MyAppointmentTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gradientStart,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: BlocBuilder<AppointmentTabCubit, bool>(
          builder: (context, isUpcoming) {
            return Row(
              children: [
                MyAppointmentTabItem(
                  label: 'Upcoming',
                  icon: Icons.upcoming_rounded,
                  isSelected: isUpcoming,
                  onTap: () =>
                      context.read<AppointmentTabCubit>().selectUpcoming(),
                ),
                MyAppointmentTabItem(
                  label: 'Past',
                  icon: Icons.history_rounded,
                  isSelected: !isUpcoming,
                  onTap: () =>
                      context.read<AppointmentTabCubit>().selectPast(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}