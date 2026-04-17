import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/my_appointment/appointment_tab_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_view.dart';


class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppointmentTabCubit(),
      child: const MyAppointmentsView(),
    );
  }
}
