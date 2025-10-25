import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/core/handlers/sign_up_handler.dart';
import 'package:second_project/core/utils/validators.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/login_screen.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/login_link.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/sign_up_button.dart';
import 'package:second_project/presentation/screens/auth/sign_up/widgets/text_field_signup.dart';

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
      backgroundColor: const Color(0xFFF7FAFF),
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) => handler.handleSignUpState(context, state),
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
                        CustomTextField(
                          controller: _firstNameController,
                          hintText: 'First Name',
                          prefixIcon: CupertinoIcons.person,
                          keyboardType: TextInputType.name,
                          validator: (value) => Validators.nameValidator(value, 'First Name'),
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: _lastNameController,
                          hintText: 'Last Name',
                          prefixIcon: CupertinoIcons.person,
                          keyboardType: TextInputType.name,
                          validator: (value) => Validators.nameValidator(value, 'Last Name'),
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.emailValidator,
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          keyboardType: TextInputType.text,
                          validator: Validators.strongPasswordValidator,
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock_outline,
                          validator: (value) => Validators.confirmPasswordValidator(value, _passwordController.text),
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
                              MaterialPageRoute(builder: (_) => LoginScreen()),
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
