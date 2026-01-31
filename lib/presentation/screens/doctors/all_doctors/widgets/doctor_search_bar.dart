import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';

class DoctorSearchBar extends StatelessWidget {
  const DoctorSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        final searchQuery = state is DoctorLoaded ? state.searchQuery : '';

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: ValueKey(searchQuery),
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.collapsed(offset: searchQuery.length),
            onChanged: (value) {
              context.read<DoctorBloc>().add(SearchDoctorsEvent(value));
            },
            decoration: InputDecoration(
              hintText: 'Search by doctor name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        context.read<DoctorBloc>().add(ResetSearchEvent());
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
      },
    );
  }
}