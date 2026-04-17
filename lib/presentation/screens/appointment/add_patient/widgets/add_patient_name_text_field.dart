import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_text_field.dart';

class AddPatientNameTextField extends StatelessWidget {
  final TextEditingController controller;
 
  const AddPatientNameTextField({required this.controller, super.key});
 
  @override
  Widget build(BuildContext context) {
    return AddPatientTextField(
      controller: controller,
      label: 'Patient Name',
      hint: 'Enter patient name',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter patient name';
        }
        return null;
      },
    );
  }
}