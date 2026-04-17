import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/appointment/patient_detail_cubit.dart';

class AddPatientSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PatientDetailsCubit cubit;
 
  const AddPatientSubmitButton({
    required this.formKey,
    required this.cubit,
    super.key
  });
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => cubit.submitForm(formKey),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.elevatedBgColor,
          foregroundColor: AppColors.backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}