import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_state.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_body.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_header.dart';

class FavoriteDoctorsScreen extends StatelessWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            return Column(
              children: [
                FavoritesHeader(count: state.favoriteDoctors.length),
                Expanded(child: FavoritesBody(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}
