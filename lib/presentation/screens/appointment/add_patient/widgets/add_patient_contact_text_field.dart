import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/add_patient/widgets/add_patient_text_field.dart';

class AddPatientContactTextField extends StatelessWidget {
  final TextEditingController controller;
 
  const AddPatientContactTextField({required this.controller, super.key});
 
  @override
  Widget build(BuildContext context) {
    return AddPatientTextField(
      controller: controller,
      label: 'Contact Number',
      hint: 'Enter contact number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter contact number';
        }
        if (value.trim().length < 10) {
          return 'Please enter a valid contact number';
        }
        return null;
      },
    );
  }
}