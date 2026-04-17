// lib/presentation/screens/available_specialists/available_specialists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/services/doctor_availability_service.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/available_specialists_view.dart';

class AvailableSpecialistsScreen extends StatelessWidget {
  const AvailableSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        context.read<DoctorRepository>(),
        DoctorAvailabilityService(FirebaseFirestore.instance),
      )..add(LoadAllDoctorsEvent()),
      child: const AvailableSpecialistsView(),
    );
  }
}
