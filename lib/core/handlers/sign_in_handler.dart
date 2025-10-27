import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_state.dart';
import 'package:second_project/presentation/bottom_nav/bottom_screen.dart';

class SignInHandler {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignInHandler({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  void handleSignInState(BuildContext context, SignInState state) {
    if (state is SignInSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      _clearFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomScreen()),
      );
    } else if (state is SignInFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void handleSignIn(BuildContext context) {
    if (formKey.currentState!.validate()) {
      context.read<SignInBloc>().add(
            SignInSubmitted(
              email: emailController.text.trim(),
              password: passwordController.text,
            ),
          );
    }
  }

  void handleGoogleSignIn(BuildContext context) {
    context.read<SignInBloc>().add(const SignInWithGoogleSubmitted());
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }
}