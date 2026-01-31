// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:idoc_user/logic/blocs/category/category_bloc.dart';
// import 'package:idoc_user/logic/blocs/category/category_event.dart';
// import 'package:idoc_user/logic/blocs/category/category_state.dart';
// import 'package:idoc_user/presentation/screens/categories/category_doctors_screen.dart';

// class AllCategoriesScreen extends StatelessWidget {
//   const AllCategoriesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE6EFF9),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'All Categories',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: BlocBuilder<CategoryBloc, CategoryState>(
//         builder: (context, state) {
//           if (state is CategoryLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is CategoryError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     state.message,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<CategoryBloc>().add(LoadCategoriesEvent());
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is CategoryLoaded) {
//             final categories = state.categories;

//             if (categories.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.category_outlined,
//                         size: 80, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No categories available',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return GridView.builder(
//               padding: const EdgeInsets.all(20),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 15,
//                 mainAxisSpacing: 15,
//                 childAspectRatio: 0.85,
//               ),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
//                 return _buildCategoryCard(context, category);
//               },
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildCategoryCard(BuildContext context, category) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CategoryDoctorsScreen(
//               categoryName: category.name,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CachedNetworkImage(
//               imageUrl: category.imageUrl,
//               width: 50,
//               height: 50,
//               fit: BoxFit.contain,
//               placeholder: (context, url) => const SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: Center(
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//               errorWidget: (context, url, error) => const Icon(
//                 Icons.medical_services,
//                 size: 50,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               category.name,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }