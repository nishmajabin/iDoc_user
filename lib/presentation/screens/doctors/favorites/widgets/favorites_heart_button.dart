import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/logic/cubits/favourite/heart_button_cubit.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_heart_button_content.dart';

class FavoritesHeartButton extends StatelessWidget {
  final DoctorModel doctor;
  const FavoritesHeartButton({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HeartButtonCubit(),
      child: FavoritesHeartButtonContent(doctor: doctor),
    );
  }
}