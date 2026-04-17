import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/cubits/search_bar/search_bar_cubit.dart';

class SpecialistsSearchField extends StatelessWidget {
  const SpecialistsSearchField({
    required this.controller,
    required this.query,
    super.key,
  });

  final TextEditingController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchBarCubit>();
    final doctorBloc = context.read<DoctorBloc>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          cubit.onChanged(value);
          doctorBloc.add(SearchDoctorsEvent(value));
        },
        decoration: InputDecoration(
          hintText: 'Search by doctor name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    cubit.clear();
                    doctorBloc.add(ResetSearchEvent());
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFE6EFF9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}