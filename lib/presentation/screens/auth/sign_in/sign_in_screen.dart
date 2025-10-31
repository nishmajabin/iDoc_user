import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/core/handlers/sign_in_handler.dart';
import 'package:second_project/core/utils/validators.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/forgot_password_screen.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/google_sign_in_button.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/gradient_title.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/labeled_text_field.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/register_link.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/styled_button.dart';
import 'package:second_project/presentation/screens/auth/sign_up/sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final handler = SignInHandler(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _pdController,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) => handler.handleSignInState(context, state),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
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
                      onPressed: () => handler.handleSignIn(context),
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
                      onPressed: () => handler.handleGoogleSignIn(context),
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
