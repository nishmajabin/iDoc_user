
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/search_bar/search_bar_cubit.dart';
import 'package:idoc_user/presentation/screens/available_specialists/widgets/specialists_search_bar_body.dart';



class SpecialistsSearchBar extends StatelessWidget {
  const SpecialistsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBarCubit>(
      create: (_) => SearchBarCubit(),
      child: const SpecialistsSearchBarBody(),
    );
  }
}
