import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20up/sign_up_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20up/sign_up_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign%20up/sign_up_state.dart';
import 'package:second_project/presentation/bottom%20nav/bottom_screen.dart';
import 'package:second_project/presentation/screens/authentication/sign%20in/login_screen.dart';
import 'package:second_project/presentation/screens/home/home_screen.dart';
import 'package:second_project/presentation/widgets/text_form_field.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Clear fields
            _firstNameController.clear();
            _lastNameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();

            // Navigate to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomScreen()),
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
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 186, 232, 255),
                Colors.white,
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.1),
                Text(
                  'SIGN UP',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // First Name Field
                        CustomTextInputField(
                          autoValidateMode:
                              AutovalidateMode.onUserInteraction,
                          controller: _firstNameController,
                          hintText: 'First Name',
                          prefixIcon: CupertinoIcons.person,
                          borderColor: Colors.transparent,
                          keyboardType: TextInputType.name,
                          addShadow: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the First Name';
                            }

                            final nameRegex = RegExp(r'^[a-zA-Z]+$');
                            if (!nameRegex.hasMatch(value)) {
                              return 'Only alphabets are allowed';
                            }

                            if (value.length < 4) {
                              return 'Require at least 4 characters long';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Last Name Field
                        CustomTextInputField(
                          autoValidateMode:
                              AutovalidateMode.onUserInteraction,
                          controller: _lastNameController,
                          hintText: 'Last Name',
                          prefixIcon: CupertinoIcons.person,
                          borderColor: Colors.transparent,
                          keyboardType: TextInputType.name,
                          addShadow: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Last Name';
                            }

                            final nameRegex = RegExp(r'^[a-zA-Z]+$');
                            if (!nameRegex.hasMatch(value)) {
                              return 'Only alphabets are allowed';
                            }

                            if (value.length < 4) {
                              return 'Require at least 4 characters long';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Email Field
                        CustomTextInputField(
                          autoValidateMode:
                              AutovalidateMode.onUserInteraction,
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.mail_outline,
                          borderColor: Colors.transparent,
                          keyboardType: TextInputType.emailAddress,
                          addShadow: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Email';
                            }

                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );

                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid Email';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Password Field
                        CustomTextInputField(
                          autoValidateMode:
                              AutovalidateMode.onUserInteraction,
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          borderColor: Colors.transparent,
                          addShadow: true,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password';
                            }

                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }

                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Password must contain at least 1 uppercase letter';
                            }

                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return 'Password must contain at least 1 lowercase letter';
                            }

                            if (!RegExp(r'\d').hasMatch(value)) {
                              return 'Password must contain at least 1 number';
                            }

                            if (!RegExp(
                              r'[!@#$%^&*(),.?":{}|<>]',
                            ).hasMatch(value)) {
                              return 'Password must contain at least 1 special character';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Confirm Password Field
                        CustomTextInputField(
                          autoValidateMode:
                              AutovalidateMode.onUserInteraction,
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock_outline,
                          borderColor: Colors.transparent,
                          addShadow: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Password to confirm';
                            }

                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 55),
                        // Sign Up Button
                        BlocBuilder<SignUpBloc, SignUpState>(
                          builder: (context, state) {
                            final isLoading = state is SignUpLoading;

                            return SizedBox(
                              width: 280,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<SignUpBloc>().add(
                                                SignUpSubmitted(
                                                  firstName:
                                                      _firstNameController.text
                                                          .trim(),
                                                  lastName:
                                                      _lastNameController.text
                                                          .trim(),
                                                  email:
                                                      _emailController.text
                                                          .trim(),
                                                  password:
                                                      _passwordController.text,
                                                  confirmPassword:
                                                      _confirmPasswordController
                                                          .text,
                                                ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    side: const BorderSide(
                                      color: Color(0xFF6AD2FF),
                                      width: 5,
                                    ),
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 22),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'NEXT',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 17.5,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        // Login Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0D72A6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                         LoginScreen(),
                                        ),
                                      );
                                    },
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}