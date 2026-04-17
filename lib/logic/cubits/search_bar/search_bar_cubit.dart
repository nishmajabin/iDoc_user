import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/search_bar/search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit()
      : super(
          SearchBarState(
            controller: TextEditingController(),
            query: '',
          ),
        );

  // ── Public API ───────────────────────────────────────────────────────────
  void onChanged(String value) {
    emit(state.copyWith(query: value));
  }

  void clear() {
    state.controller.clear();
    emit(state.copyWith(query: ''));
  }

  void syncFromBloc(String query) {
    if (state.controller.text == query) return; 

    final previousSelection = state.controller.selection;
    state.controller.text = query;

    // Restore cursor only if it still falls within the new text bounds.
    final restoredOffset = previousSelection.baseOffset <= query.length
        ? previousSelection.baseOffset
        : query.length;

    state.controller.selection =
        TextSelection.collapsed(offset: restoredOffset);

    emit(state.copyWith(query: query));
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    state.controller.dispose();
    return super.close();
  }
}