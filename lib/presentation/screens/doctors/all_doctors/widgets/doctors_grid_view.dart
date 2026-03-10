import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/doctors/all_doctors/widgets/doctor_grid_card.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';

class DoctorsGridView extends StatelessWidget {
  const DoctorsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return const _LoadingView();
        }

        if (state is DoctorError) {
          return _ErrorView(message: state.message);
        }

        if (state is DoctorLoaded) {
          final doctors = state.doctors;

          if (doctors.isEmpty) {
            return _EmptyView(searchQuery: state.searchQuery);
          }

          return _DoctorsGrid(doctors: doctors);
        }

        return const SizedBox.shrink();
      },
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

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DoctorBloc>().add(RetryLoadDoctorsEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String searchQuery;

  const _EmptyView({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'No doctors found'
                : 'No doctors available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _DoctorsGrid extends StatelessWidget {
  final List<dynamic> doctors;

  const _DoctorsGrid({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        return DoctorGridCard(doctor: doctors[index]);
      },
    );
  }
}