import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/core/constants/color.dart';
import 'package:second_project/logic/blocs/profile/profile_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';
import 'package:second_project/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_header.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_avatar.dart';
import 'package:second_project/presentation/screens/profile/widgets/profile_info_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProfileBloc>().add(const FetchUserProfile());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            );
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 1.5,
                ),
              );
            }

            if (state is ProfileSuccess) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 250),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              ProfileInfoField(
                                label: 'Name',
                                value: state.name,
                              ),
                              const SizedBox(height: 20),
                              ProfileInfoField(
                                label: 'Email',
                                value: state.email,
                              ),
                              const SizedBox(height: 20),
                              const ProfileInfoField(
                                label: 'Mobile Number',
                                value: 'Not provided',
                                isPlaceholder: true,
                              ),
                              const SizedBox(height: 20),
                              ProfileInfoField(
                                label: 'Address',
                                value: state.address.isNotEmpty
                                    ? state.address
                                    : 'Not provided',
                                isPlaceholder: state.address.isEmpty,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProfileHeader(
                    onBackPressed: () => Navigator.pop(context),
                    onEditPressed: () {

                    },
                  ),
                  ProfileAvatar(
                    imageUrl: state.profileImageUrl,
                    topPosition: MediaQuery.of(context).padding.top + 90,
                  ),
                ],
              );
            }

            if (state is ProfileFailure) {
              return Center(child: Text(state.error));
            }

            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}