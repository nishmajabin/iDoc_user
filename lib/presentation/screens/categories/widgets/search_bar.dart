import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

class DoctorsSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const DoctorsSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    required this.onClear,
  });

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
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
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