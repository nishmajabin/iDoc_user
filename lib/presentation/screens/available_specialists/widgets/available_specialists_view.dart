import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/active_filters_display.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/filter_button.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_grid_view.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_search_bar.dart';

class AvailableSpecialistsView extends StatelessWidget {
  const AvailableSpecialistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forgetPdBg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SpecialistsSearchBar(),
          // Use BlocBuilder to ensure it rebuilds
          BlocBuilder<DoctorBloc, DoctorState>(
            builder: (context, state) {
              if (state is DoctorLoaded) {}
              return const ActiveFiltersDisplay();
            },
          ),
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorLoaded) {}
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
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      title: Text(
        'Available Specialists',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: const [FilterButton()],
    );
  }

  Widget _buildBody(BuildContext context, DoctorState state) {
    if (state is DoctorLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
            color: AppColors.backgroundColor,
            child: Row(
              children: [
                Text(
                  '${state.doctors.length} doctor${state.doctors.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SpecialistsGridView(doctors: state.doctors)),
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
            Icon(Icons.error_outline, size: 64, color: AppColors.errorIcon),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextColor2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
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
              color: AppColors.lightText,
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
                color: AppColors.lightTextColor,
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
              style: TextStyle(fontSize: 14, color: AppColors.lightTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
