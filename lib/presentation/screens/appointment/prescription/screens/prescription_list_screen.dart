import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/prescription_service.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_bloc.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_event.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_list_body.dart';

class PrescriptionListScreen extends StatelessWidget {
  final String userId;

  const PrescriptionListScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPrescriptionBloc(
        UserPrescriptionService(FirebaseFirestore.instance),
      )..add(FetchUserPrescriptions(userId)),
      child: PrescriptionListBody(userId: userId),
    );
  }
}
