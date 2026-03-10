import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/user_model.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_bloc.dart';
import 'package:idoc_user/logic/blocs/bottom_nav/bottom_nav_state.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/presentation/screens/home/widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Load data when screen builds
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
    context.read<DoctorBloc>().add(LoadAllDoctorsEvent());

    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE6EFF9),
          body: HomeBodySection(user: user)
        );
      },
    );
  }
}
