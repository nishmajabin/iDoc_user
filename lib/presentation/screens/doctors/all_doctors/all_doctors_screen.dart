// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:idoc_user/data/repostories/doctor_repository.dart';
// import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
// import 'package:idoc_user/presentation/screens/doctors/all_doctors/widgets/doctor_search_bar.dart';
// import 'package:idoc_user/presentation/screens/doctors/all_doctors/widgets/doctors_grid_view.dart';
// import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';

// class AllDoctorsScreen extends StatelessWidget {
//   const AllDoctorsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DoctorBloc(
//         context.read<DoctorRepository>(),
//       )..add(LoadAllDoctorsEvent()),
//       child: const AllDoctorsView(),
//     );
//   }
// }

// class AllDoctorsView extends StatelessWidget {
//   const AllDoctorsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE6EFF9),
//       appBar: _buildAppBar(context),
//       body: const Column(
//         children: [
//           DoctorSearchBar(),
//           Expanded(child: DoctorsGridView()),
//         ],
//       ),
//     );
//   }

//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black87),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: const Text(
//         'All Doctors',
//         style: TextStyle(
//           color: Colors.black87,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
// lib/presentation/screens/doctors/all_doctors/all_doctors_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/services/doctor_availability_service.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/presentation/screens/doctors/all_doctors/widgets/doctor_search_bar.dart';
import 'package:idoc_user/presentation/screens/doctors/all_doctors/widgets/doctors_grid_view.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';

class AllDoctorsScreen extends StatelessWidget {
  const AllDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        context.read<DoctorRepository>(),
        DoctorAvailabilityService(FirebaseFirestore.instance),
      )..add(LoadAllDoctorsEvent()),
      child: const AllDoctorsView(),
    );
  }
}

class AllDoctorsView extends StatelessWidget {
  const AllDoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EFF9),
      appBar: _buildAppBar(context),
      body: const Column(
        children: [
          DoctorSearchBar(),
          Expanded(child: DoctorsGridView()),
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
        'All Doctors',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}