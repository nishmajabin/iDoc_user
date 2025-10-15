import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:second_project/presentation/screens/auth/sign_up.dart';
import 'package:second_project/presentation/screens/home/home_screen.dart';
import 'package:second_project/presentation/widgets/text_form_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFF052C40),
  );

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),

              Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF052C40), Color(0xFF0D72A6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'LOGIN',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: Color.fromRGBO(13, 114, 166, 0.4),
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenSize.height * 0.04),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('EMAIL', style: labelStyle),
                    ),
                    const SizedBox(height: 8),
                    buildTextInputField(
                      controller: _emailController,
                      hintText: 'RT8918351@GMAIL.COM',
                      prefixIcon: Icons.email_outlined,
                      borderColor: Color(0xFF052C40),
                      borderWidth: 0.9,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.03),

   Align(
    alignment: Alignment.centerLeft,
    child: Text('Password', style: labelStyle)),
                    const SizedBox(height: 8),
                    buildTextInputField(
                      controller: _pdController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      borderColor: Colors.transparent,
                      backgroundColor: Color(0xFFF5F5F5),
                      isPassword: true,
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => log('Forgot Password tapped'),
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

              Center(
                child: Container(
                  width: double.infinity,
                  height: 65,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D72A6).withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      String mail = _emailController.text;
                      String pass = _pdController.text;
                      if (mail.isEmpty && pass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter all the fields!'),
                          ),
                        );
                      } else {
                        try {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: mail,
                                password: pass,
                              )
                              .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('login successful!')),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              });
                        } catch (e) {
                          throw Exception(e);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF052C40),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: const BorderSide(
                          color: Color(0xFF6AD2FF),
                          width: 4,
                        ),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
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

              OutlinedButton.icon(
                onPressed: () => log('Google sign up tapped'),
                icon: Image.asset('assets/images/google.png', height: 24),
                label: const Text(
                  'Sign up with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  side: const BorderSide(color: Color(0xFF052C40), width: 0.8),
                ),
              ),

              SizedBox(height: screenSize.height * 0.1),

              // --- 8. Don't have an account? ---
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: labelStyle.copyWith(color: const Color(0xFF555555)),
                    children: [
                      TextSpan(
                        text: 'Register now',
                        style: labelStyle.copyWith(
                          color: const Color(0xFF0D72A6), // Blue link
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpScreen(),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
