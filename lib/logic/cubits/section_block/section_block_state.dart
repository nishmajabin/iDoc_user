import 'package:equatable/equatable.dart';

abstract class SectionBlockState extends Equatable {
  const SectionBlockState();

  @override
  List<Object?> get props => [];
}

/// The accordion panel is collapsed.
class SectionBlockCollapsed extends SectionBlockState {
  const SectionBlockCollapsed();
}

/// The accordion panel is expanded.
class SectionBlockExpanded extends SectionBlockState {
  const SectionBlockExpanded();
}