import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

class SpecialistsSearchBar extends StatefulWidget {
  const SpecialistsSearchBar({super.key});

  @override
  State<SpecialistsSearchBar> createState() => _SpecialistsSearchBarState();
}

class _SpecialistsSearchBarState extends State<SpecialistsSearchBar> {
  // Create controller once and reuse it - this prevents focus loss
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorBloc, DoctorState>(
      // Listen to state changes and update controller text only when needed
      listener: (context, state) {
        if (state is DoctorLoaded) {
          // Only update if the search query in state differs from controller
          // This prevents cursor jumping and maintains focus
          if (_controller.text != state.searchQuery) {
            final selection = _controller.selection;
            _controller.text = state.searchQuery;
            // Restore cursor position
            if (selection.baseOffset <= state.searchQuery.length) {
              _controller.selection = selection;
            } else {
              _controller.selection = TextSelection.collapsed(
                offset: state.searchQuery.length,
              );
            }
          }
        }
      },
      child: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          final searchQuery = state is DoctorLoaded ? state.searchQuery : '';

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
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
                          _controller.clear();
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
      ),
    );
  }
}