import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/services/payment_service.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/cubits/appointment/patient_detail_cubit.dart';
import 'package:idoc_user/logic/cubits/appointment/patient_detail_state.dart';
import 'package:idoc_user/logic/cubits/slot/slot_selection_cubit.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_contact_text_field.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_description_text_field.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_doctor_card.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_name_shimmer.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_name_text_field.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_submit_button.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/prefilled_name_card.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/screens/slot_selection_screen.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/consultation_fee_display.dart';

class AddPatientDetailsView extends StatelessWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;
  final AppointmentBloc appointmentBloc;

  final _formKey = GlobalKey<FormState>();

  AddPatientDetailsView({
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialist,
    required this.doctorProfileImageUrl,
    required this.consultationFee,
    required this.appointmentBloc,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PatientDetailsCubit>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Appointment'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.shadowDark,
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          // Navigate to slot selection when patient details are confirmed.
          if (state is PatientDetailsSet) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  final paymentBloc = context.read<PaymentBloc>();
                  final paymentService = context.read<PaymentService>();

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: appointmentBloc),
                      BlocProvider<SlotCubit>(
                        lazy: false,
                        create: (_) => SlotCubit(
                          paymentService: paymentService,
                          paymentBloc: paymentBloc,
                          appointmentBloc: appointmentBloc,
                          doctorId: doctorId,
                        )..initialize(),
                      ),
                    ],
                    child: SlotSelectionScreen(
                      consultationFee: consultationFee,
                      doctorId: doctorId,
                      doctorName: doctorName,
                      doctorSpecialist: doctorSpecialist,
                      doctorProfileImageUrl: doctorProfileImageUrl,
                    ),
                  );
                },
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Doctor card ────────────────────────────────────────
                  AddPatientDoctorCard(
                    doctorName: doctorName,
                    doctorSpecialist: doctorSpecialist,
                    doctorProfileImageUrl: doctorProfileImageUrl,
                  ),
                  const SizedBox(height: 24),

                  // ── Consultation fee ───────────────────────────────────
                  ConsultationFeeDisplay(consultationFee: consultationFee),
                  const SizedBox(height: 32),

                  Text(
                    'Appointment For',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextColor2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Patient name — shimmer / pre-filled card / text field
                  // Only rebuilds this slice of the tree.
                  BlocBuilder<PatientDetailsCubit, PatientDetailsFormState>(
                    buildWhen:
                        (prev, curr) =>
                            prev.isNameLoading != curr.isNameLoading ||
                            prev.isNamePrefilled != curr.isNamePrefilled,
                    builder: (context, formState) {
                      if (formState.isNameLoading) {
                        return const AddPatientNameShimmer();
                      }
                      if (formState.isNamePrefilled) {
                        return PrefilledNameCard(
                          nameController: formState.nameController,
                        );
                      }
                      return AddPatientNameTextField(
                        controller: formState.nameController,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Contact number ─────────────────────────────────────
                  // Read controllers once from the cubit — they never change.
                  AddPatientContactTextField(controller: cubit.state.contactController),
                  const SizedBox(height: 16),

                  // ── Reason for appointment ─────────────────────────────
                  AddPatientDescriptionTextField(
                    controller: cubit.state.descriptionController,
                  ),
                  const SizedBox(height: 32),

                  // ── Next button ────────────────────────────────────────
                  AddPatientSubmitButton(formKey: _formKey, cubit: cubit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
