import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/core/utils/validators.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20in/sign_in_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20in/sign_in_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20in/sign_in_state.dart';
import 'package:second_project/presentation/bottom%20nav/bottom_screen.dart';
import 'package:second_project/presentation/screens/authentication/sign%20up/sign_up.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/widgets/google_sign_in_button.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/widgets/gradient_title.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/widgets/labeled_text_field.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/widgets/register_link.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/widgets/styled_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            _emailController.clear();
            _pdController.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomScreen()),
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
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                const GradientTitle(text: 'LOGIN'),
                SizedBox(height: screenSize.height * 0.04),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      LabeledTextField(
                        label: 'EMAIL',
                        controller: _emailController,
                        hintText: 'RT8918351@GMAIL.COM',
                        prefixIcon: Icons.email_outlined,
                        borderColor: const Color(0xFF052C40),
                        borderWidth: 0.9,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.emailValidator,
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      LabeledTextField(
                        label: 'Password',
                        controller: _pdController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        backgroundColor: const Color(0xFFF5F5F5),
                        isPassword: true,
                        validator: Validators.passwordValidator,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF0058CB),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                BlocBuilder<SignInBloc, SignInState>(
                  builder: (context, state) {
                    return StyledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<SignInBloc>().add(
                                SignInSubmitted(
                                  email: _emailController.text.trim(),
                                  password: _pdController.text,
                                ),
                              );
                        }
                      },
                      label: 'LOGIN',
                      isLoading: state is SignInLoading,
                    );
                  },
                ),
                SizedBox(height: screenSize.height * 0.03),
                const Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                BlocBuilder<SignInBloc, SignInState>(
                  builder: (context, state) {
                    return GoogleSignInButton(
                      onPressed: () {
                        context.read<SignInBloc>().add(
                              const SignInWithGoogleSubmitted(),
                            );
                      },
                      isDisabled: state is SignInLoading,
                    );
                  },
                ),
                SizedBox(height: screenSize.height * 0.1),
                RegisterLink(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}