import 'package:equatable/equatable.dart';

abstract class FaqTileState extends Equatable {
  const FaqTileState();

  @override
  List<Object?> get props => [];
}

/// The FAQ tile is collapsed (default).
class FaqTileCollapsed extends FaqTileState {
  const FaqTileCollapsed();
}

/// The FAQ tile is expanded, showing the answer.
class FaqTileExpanded extends FaqTileState {
  const FaqTileExpanded();
}