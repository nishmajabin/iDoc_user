import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/core/handlers/sign_up_handler.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/login_link.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/sign_up_button.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/user_form_fields.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final handler = SignUpHandler(
      formKey: _formKey,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
    );

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) => handler.handleSignUpState(context, state),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientColor,
                AppColors.gradientMainColor.withValues(alpha: 0.01),
              ],
              stops: const [0.1, 1],
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
                    color: AppColors.primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        UserFormFields(
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                        ),
                        const SizedBox(height: 55),
                        BlocBuilder<SignUpBloc, SignUpState>(
                          builder: (context, state) {
                            return SignUpButton(
                              onPressed: () => handler.handleSignUp(context),
                              isLoading: state is SignUpLoading,
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        LoginLink(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => SignInScreen()),
                            );
                          },
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
