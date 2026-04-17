import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/faq_tile/faq_tile_state.dart';

class FaqTileCubit extends Cubit<FaqTileState> {
  FaqTileCubit() : super(const FaqTileCollapsed());

  /// Called by [ExpansionTile.onExpansionChanged].
  void onExpansionChanged(bool isExpanded) {
    if (isClosed) return;
    emit(isExpanded ? const FaqTileExpanded() : const FaqTileCollapsed());
  }
}