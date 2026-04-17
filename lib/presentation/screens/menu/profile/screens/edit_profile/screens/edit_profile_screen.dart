import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'package:idoc_user/logic/cubits/edit_profile/edit_profile_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/profile/screens/edit_profile/widgets/edit_profile_view.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileSuccess profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileCubit(
        profileBloc: context.read<ProfileBloc>(),
      ),
      child: EditProfileView(profileData: profileData),
    );
  }
}
