import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/my_appointment/appointment_shimmer_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/my_appointment_shimmer_card.dart';

class MyAppointmentShimmerList extends StatelessWidget {
  const MyAppointmentShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShimmerCubit(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: 4,
        itemBuilder: (_, __) => const MyAppointmentShimmerCard(),
      ),
    );
  }
}