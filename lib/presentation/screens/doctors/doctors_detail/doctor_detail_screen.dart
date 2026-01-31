import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_bloc.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_event.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_state.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_detail_content.dart';

class DoctorDetailScreen extends StatelessWidget {
  final String doctorId;

  const DoctorDetailScreen({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorDetailBloc(
        context.read<DoctorRepository>(),
      )..add(LoadDoctorDetailEvent(doctorId)),
      child: DoctorDetailView(doctorId: doctorId),
    );
  }
}

class DoctorDetailView extends StatelessWidget {
  final String doctorId;

  const DoctorDetailView({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EFF9),
      body: BlocBuilder<DoctorDetailBloc, DoctorDetailState>(
        builder: (context, state) {
          if (state is DoctorDetailLoading) {
            return const _LoadingView();
          }

          if (state is DoctorDetailError) {
            return _ErrorView(
              message: state.message,
              doctorId: doctorId,
            );
          }

          if (state is DoctorDetailLoaded) {
            return DoctorDetailContent(doctor: state.doctor);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String doctorId;

  const _ErrorView({
    required this.message,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<DoctorDetailBloc>()
                  .add(RetryLoadDoctorDetailEvent(doctorId));
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}