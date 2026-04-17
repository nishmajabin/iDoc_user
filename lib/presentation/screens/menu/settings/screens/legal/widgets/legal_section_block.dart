import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/legal_section_model.dart';
import 'package:idoc_user/logic/cubits/section_block/section_block_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/legal/widgets/legal_section_block_content.dart';

class LegalSectionBlock extends StatelessWidget {
  final LegalSection section;

  const LegalSectionBlock({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SectionBlockCubit(initiallyExpanded: section.initiallyExpanded),
      child: LegalSectionBlockContent(section: section),
    );
  }
}