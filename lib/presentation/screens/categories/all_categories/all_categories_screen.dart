
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/category/category_state.dart';
import 'package:idoc_user/presentation/screens/categories/all_categories/widget/category_grid.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/app_scaffold.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/empty_view.dart';
import 'package:idoc_user/presentation/screens/categories/widgets/error_view.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'All Categories',
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<CategoryBloc>().add(LoadCategoriesEvent()),
            );
          }

          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const EmptyView(
                icon: Icons.category_outlined,
                message: 'No categories available',
              );
            }
            return CategoryGrid(categories: state.categories);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}