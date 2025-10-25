import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_state.dart';
import 'package:second_project/presentation/bottom_nav/bottom_screen.dart';

class SignUpHandler {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  SignUpHandler({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  void handleSignUpState(BuildContext context, SignUpState state) {
    if (state is SignUpSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      _clearAllFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomScreen()),
      );
    } else if (state is SignUpFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void handleSignUp(BuildContext context) {
    if (formKey.currentState!.validate()) {
      context.read<SignUpBloc>().add(
            SignUpSubmitted(
              firstName: firstNameController.text.trim(),
              lastName: lastNameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
            ),
          );
    }
  }

  void _clearAllFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}