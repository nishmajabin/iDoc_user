import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctors_list.dart';

class DoctorsListHome extends StatelessWidget {
  const DoctorsListHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DoctorError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load doctors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is DoctorLoaded) {
          return buildDoctorsListVertical(state.doctors);
        }

        return buildDoctorsListVertical([]);
      },
    );
  }
}