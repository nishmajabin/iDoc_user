import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/logic/cubits/search_bar/search_bar_cubit.dart';
import 'package:idoc_user/logic/cubits/search_bar/search_bar_state.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_search_field.dart';

class SpecialistsSearchBarBody extends StatelessWidget {
  const SpecialistsSearchBarBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorBloc, DoctorState>(
      listener: (context, doctorState) {
        if (doctorState is DoctorLoaded) {
          context.read<SearchBarCubit>().syncFromBloc(doctorState.searchQuery);
        }
      },
      child: BlocBuilder<SearchBarCubit, SearchBarState>(
        buildWhen: (previous, current) => previous.query != current.query,
        builder: (context, searchState) {
          return SpecialistsSearchField(
            controller: searchState.controller,
            query: searchState.query,
          );
        },
      ),
    );
  }
}
