// lib/presentation/screens/available_specialists/available_specialists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/services/doctor_availability_service.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/active_filters_display.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/filter_button.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_grid_view.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_search_bar.dart';

class AvailableSpecialistsScreen extends StatelessWidget {
  const AvailableSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        context.read<DoctorRepository>(),
        DoctorAvailabilityService(FirebaseFirestore.instance),
      )..add(LoadAllDoctorsEvent()),
      child: const _AvailableSpecialistsView(),
    );
  }
}

class _AvailableSpecialistsView extends StatelessWidget {
  const _AvailableSpecialistsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EFF9),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SpecialistsSearchBar(),
          // Use BlocBuilder to ensure it rebuilds
          BlocBuilder<DoctorBloc, DoctorState>(
            builder: (context, state) {
              print('🔄 Rebuilding ActiveFiltersDisplay area');
              print('   State: ${state.runtimeType}');
              if (state is DoctorLoaded) {
                print('   Has active filters: ${state.filter.hasActiveFilters}');
                print('   Filter count: ${state.filter.activeFilterCount}');
              }
              return const ActiveFiltersDisplay();
            },
          ),
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                print('🔄 Main body rebuilding with state: ${state.runtimeType}');
                if (state is DoctorLoaded) {
                  print('   Doctors: ${state.doctors.length}');
                  print('   Has active filters: ${state.filter.hasActiveFilters}');
                }
                return _buildBody(context, state);
              },
            ),
          ),
        ],
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
        'Available Specialists',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: const [
        FilterButton(),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DoctorState state) {
    if (state is DoctorLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is DoctorError) {
      return _buildErrorView(context, state.message);
    }

    if (state is DoctorLoaded) {
      if (state.doctors.isEmpty) {
        return _buildEmptyView(
          state.searchQuery,
          state.filter.hasActiveFilters,
        );
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  '${state.doctors.length} doctor${state.doctors.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SpecialistsGridView(doctors: state.doctors),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DoctorBloc>().add(RetryLoadDoctorsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String searchQuery, bool hasActiveFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.filter_list_off : Icons.person_search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters
                  ? 'No doctors match your filters'
                  : searchQuery.isNotEmpty
                      ? 'No doctors found'
                      : 'No doctors available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Try adjusting your filter criteria'
                  : searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Check back later for available doctors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}