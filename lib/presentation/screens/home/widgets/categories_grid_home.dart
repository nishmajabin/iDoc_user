import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
import 'package:idoc_user/logic/blocs/category/category_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/category_card.dart';

class CategoriesGridHome extends StatelessWidget {
  const CategoriesGridHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoryError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (state is CategoryLoaded) {
          final categories = state.categories;

          if (categories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No categories available')),
            );
          }

          // Display first 4 categories
          final displayCategories = categories.take(4).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  displayCategories
                      .map(
                        (category) => buildCategoryCard(
                          category.imageUrl,
                          category.name,
                          onTap: () {
                            // Navigate to category details
                          },
                        ),
                      )
                      .toList(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
