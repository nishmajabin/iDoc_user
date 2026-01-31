import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/categories/category_doctors/widget/doctor_list.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/app_scaffold.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/empty_view.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/error_view.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/search_bar.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';

class CategoryDoctorsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDoctorsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        context.read<DoctorRepository>(),
      )..add(LoadDoctorsByCategoryEvent(categoryName)),
      child: CategoryDoctorsView(categoryName: categoryName),
    );
  }
}

class CategoryDoctorsView extends StatelessWidget {
  final String categoryName;

  const CategoryDoctorsView({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: categoryName,
      body: Column(
        children: [
          DoctorsSearchBar(
            hintText: 'Search doctors...',
            onSearch: (value) => context.read<DoctorBloc>().add(SearchDoctorsEvent(value)),
            onClear: () => context.read<DoctorBloc>().add(ResetSearchEvent()),
          ),
          const Expanded(child: CategoryDoctorsList()),
        ],
      ),
    );
  }
}

class CategoryDoctorsList extends StatelessWidget {
  const CategoryDoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DoctorError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<DoctorBloc>().add(RetryLoadDoctorsEvent()),
          );
        }

        if (state is DoctorLoaded) {
          if (state.doctors.isEmpty) {
            return EmptyView(
              icon: Icons.person_search,
              message: state.searchQuery.isNotEmpty
                  ? 'No doctors found'
                  : 'No doctors available in this category',
            );
          }
          return DoctorList(doctors: state.doctors);
        }

        return const SizedBox.shrink();
      },
    );
  }
}