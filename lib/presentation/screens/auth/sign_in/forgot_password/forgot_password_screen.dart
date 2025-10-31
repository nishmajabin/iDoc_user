import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/forgot_password/forgot_password_bloc.dart';
import 'package:second_project/logic/blocs/forgot_password/forgot_password_event.dart';
import 'package:second_project/logic/blocs/forgot_password/forgot_password_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/forgot_password/widgets/back_button_widget.dart';
import 'package:second_project/presentation/screens/auth/sign_in/forgot_password/widgets/email_input_field.dart';
import 'package:second_project/presentation/screens/auth/sign_in/widgets/styled_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      body: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) Navigator.pop(context);
            });
          } else if (state is ForgotPasswordError) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const BackButtonWidget(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 24),
                _buildSubtitle(),
                const SizedBox(height: 40),
                EmailInputField(
                  controller: emailController,
                  onChanged: (value) {
                    context.read<ForgotPasswordBloc>().add(EmailChanged(value));
                  },
                ),
                const SizedBox(height: 40),
                BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                  builder: (context, state) {
                    return StyledButton(
                      onPressed: () {
                        context.read<ForgotPasswordBloc>().add(const SendResetLinkPressed());
                      },
                      label: 'SEND',
                      isLoading: state is ForgotPasswordLoading,
                      height: 56,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'FORGOT PASSWORD',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please Enter Your Register\nemail',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'To Receive a Verification Code',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}