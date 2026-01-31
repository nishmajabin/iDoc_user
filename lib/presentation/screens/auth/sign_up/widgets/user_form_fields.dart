import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/utils/validators.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_event.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_state.dart';
import 'package:idoc_user/presentation/screens/auth/sign_up/widgets/text_field_signup.dart';

class UserFormFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const UserFormFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextInputField(
          controller: firstNameController,
          hintText: 'First Namne',
          labelText: 'First Name',
          prefixIcon: CupertinoIcons.person,
          keyboardType: TextInputType.name,
          validator: (value) => Validators.nameValidator(value, 'First Name'),
        ),
        const SizedBox(height: 25),
        CustomTextInputField(
          controller: lastNameController,
          hintText: 'Last Name',
          labelText: 'Last Name',
          prefixIcon: CupertinoIcons.person,
          keyboardType: TextInputType.name,
          validator: (value) => Validators.nameValidator(value, 'Last Name'),
        ),
        const SizedBox(height: 25),
        CustomTextInputField(
          controller: emailController,
          hintText: 'Email',
          labelText: 'Email',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.emailValidator,
        ),
        const SizedBox(height: 25),
        BlocBuilder<SignUpBloc, SignUpState>(
          builder: (context, state) {
            return CustomTextInputField(
              controller: passwordController,
              hintText: 'Password',
              labelText: 'Password',
              isPassword: true,
              obscureText: state.obscurePassword,
              onSuffixTap: () {
                context.read<SignUpBloc>().add(PasswordVisibilityToggled());
              },
              prefixIcon: Icons.lock_outline,
              keyboardType: TextInputType.text,
              validator: Validators.strongPasswordValidator,
            );
          },
        ),
        const SizedBox(height: 25),
        CustomTextInputField(
          controller: confirmPasswordController,
          hintText: 'Confirm password',
          labelText: 'Confirm password',
          obscureText: true,
          onSuffixTap: () {
            context.read<SignUpBloc>().add(PasswordVisibilityToggled());
          },
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.text,
          validator:
              (value) => Validators.confirmPasswordValidator(
                value,
                passwordController.text,
              ),
        ),
      ],
    );
  }
}
