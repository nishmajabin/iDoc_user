import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/cubits/appointment/patient_detail_cubit.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_details_view.dart';

class AddPatientDetailsScreen extends StatelessWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  const AddPatientDetailsScreen({
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    required this.consultationFee,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final appointmentBloc = AppointmentBloc(appointmentService: context.read());

    // Kick off the name fetch immediately.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      appointmentBloc.add(FetchPatientNameEvent(uid));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppointmentBloc>.value(value: appointmentBloc),
        BlocProvider<PatientDetailsCubit>(
          create: (_) => PatientDetailsCubit(appointmentBloc: appointmentBloc),
        ),
      ],
      child: AddPatientDetailsView(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialist: doctorSpecialist,
        doctorProfileImageUrl: doctorProfileImageUrl,
        consultationFee: consultationFee,
        appointmentBloc: appointmentBloc,
      ),
    );
  }
}
