import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/doctor_filter/doctor_filter_cubit.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_availability_section.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_consultation_fee_section.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_experience_section.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_footer.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_gender_section.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_header.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_rating_section.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/doctor_filter_specialization_section.dart';

class DoctorFilterBottomSheet extends StatelessWidget {
  const DoctorFilterBottomSheet({super.key});

  // Filter options (static / constant data)
  static const List<String> specializations = [
    'General',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
    'Neurologist',
    'Gynecologist',
    'Psychiatrist',
    'ENT Specialist',
    'Endocrinologist',
    'Nutritionist',
    'Psychologist',
  ];

  static const List<String> experienceRanges = [
    '0-1 years',
    '2-4 years',
    '5-7 years',
    '8+ years',
  ];

  static const List<String> genderOptions = ['Male', 'Female'];

  static const double minFee = 0;
  static const double maxFee = 5000;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorFilterCubit>(
      create: (ctx) {
        final cubit = DoctorFilterCubit();
        final doctorState = ctx.read<DoctorBloc>().state;
        if (doctorState is DoctorLoaded) {
          cubit.initialize(doctorState.filter);
        }
        return cubit;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const DoctorFilterHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    DoctorFilterConsultationFeeSection(),
                    SizedBox(height: 24),
                    DoctorFilterRatingSection(),
                    SizedBox(height: 24),
                    DoctorFilterSpecializationSection(),
                    SizedBox(height: 24),
                    DoctorFilterExperienceSection(),
                    SizedBox(height: 24),
                    DoctorAvailabilitySection(),
                    SizedBox(height: 24),
                    DoctorFilterGenderSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            const DoctorFilterFooter(),
          ],
        ),
      ),
    );
  }
}
