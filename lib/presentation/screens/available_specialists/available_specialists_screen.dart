import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_grid_view.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_search_bar.dart';

class AvailableSpecialistsScreen extends StatelessWidget {
  const AvailableSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        context.read<DoctorRepository>(),
      )..add(LoadAllDoctorsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFE6EFF9),
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            const SpecialistsSearchBar(),
            Expanded(
              child: BlocBuilder<DoctorBloc, DoctorState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Available Specialists...',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DoctorState state) {
    if (state is DoctorLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DoctorError) {
      return _buildErrorView(context, state.message);
    }

    if (state is DoctorLoaded) {
      return state.doctors.isEmpty
          ? _buildEmptyView(state.searchQuery)
          : SpecialistsGridView(doctors: state.doctors);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DoctorBloc>().add(RetryLoadDoctorsEvent()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? 'No doctors found' : 'No doctors available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}