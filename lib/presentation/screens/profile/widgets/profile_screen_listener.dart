import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/sign_in_screen.dart';

class ProfileScreenListener extends StatelessWidget {
  final Widget child;

  const ProfileScreenListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          _handleLogoutSuccess(context);
        } else if (state is ProfileFailure) {
          _handleProfileFailure(context, state);
        }
      },
      child: child,
    );
  }

  void _handleLogoutSuccess(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _handleProfileFailure(BuildContext context, ProfileFailure state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Automatically fetch profile again after error
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        context.read<ProfileBloc>().add(const FetchUserProfile());
      }
    });
  }
}