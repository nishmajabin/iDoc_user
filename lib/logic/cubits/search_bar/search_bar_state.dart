import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class SearchBarState extends Equatable {
  const SearchBarState({
    required this.controller,
    required this.query,
  });

  final TextEditingController controller;

  final String query;

  SearchBarState copyWith({String? query}) {
    return SearchBarState(
      controller: controller, // controller reference never changes
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [query];
}