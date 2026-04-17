import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_text_field.dart';

class AddPatientDescriptionTextField extends StatelessWidget {
  final TextEditingController controller;
 
  const AddPatientDescriptionTextField({required this.controller, super.key});
 
  @override
  Widget build(BuildContext context) {
    return AddPatientTextField(
      controller: controller,
      label: 'Reason for Appointment',
      hint: 'Describe your symptoms or reason for visit',
      icon: Icons.description_outlined,
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please describe the reason for appointment';
        }
        if (value.trim().length < 10) {
          return 'Please provide more details (at least 10 characters)';
        }
        return null;
      },
    );
  }
}