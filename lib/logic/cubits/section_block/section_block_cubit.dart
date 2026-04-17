import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/section_block/section_block_state.dart';

class SectionBlockCubit extends Cubit<SectionBlockState> {
  SectionBlockCubit({bool initiallyExpanded = false})
      : super(
          initiallyExpanded
              ? const SectionBlockExpanded()
              : const SectionBlockCollapsed(),
        );

  // Toggles between expanded and collapsed.
  void toggle() {
    if (isClosed) return;
    emit(state is SectionBlockExpanded
        ? const SectionBlockCollapsed()
        : const SectionBlockExpanded());
  }
}