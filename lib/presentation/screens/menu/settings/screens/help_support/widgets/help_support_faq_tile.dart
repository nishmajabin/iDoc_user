import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/faq_tile/faq_tile_cubit.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_faq.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_faq_tile_content.dart';

class HelpSupportFaqTile extends StatelessWidget {
  final HelpSupportFaq faq;

  const HelpSupportFaqTile({required this.faq, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaqTileCubit(),
      child: HelpSupportFaqTileContent(faq: faq),
    );
  }
}
