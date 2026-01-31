
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';
import 'package:idoc_user/presentation/screens/home/widgets/categories_section.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctors_section.dart';
import 'package:idoc_user/presentation/screens/home/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data when screen builds
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
    context.read<DoctorBloc>().add(LoadAllDoctorsEvent());

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE6EFF9),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeHeader(),
                SizedBox(height: 120),
                HomeCategoriesSection(),
                SizedBox(height: 15),
                HomeDoctorsSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}