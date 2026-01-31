// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:idoc_user/data/repostories/doctor_repository.dart';
// import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';
// import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';
// import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class CategoryDoctorsScreen extends StatelessWidget {
//   final String categoryName;

//   const CategoryDoctorsScreen({
//     super.key,
//     required this.categoryName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => DoctorBloc(
//         context.read<DoctorRepository>(),
//       )..add(LoadDoctorsByCategoryEvent(categoryName)),
//       child: CategoryDoctorsView(categoryName: categoryName),
//     );
//   }
// }

// class CategoryDoctorsView extends StatelessWidget {
//   final String categoryName;

//   const CategoryDoctorsView({
//     super.key,
//     required this.categoryName,
//   });

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
//         title: Text(
//           categoryName,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           const CategorySearchBar(),

//           // Doctors List
//           Expanded(
//             child: BlocBuilder<DoctorBloc, DoctorState>(
//               builder: (context, state) {
//                 if (state is DoctorLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (state is DoctorError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error_outline,
//                             size: 60, color: Colors.red),
//                         const SizedBox(height: 16),
//                         Text(state.message,
//                             style: const TextStyle(color: Colors.red)),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             context
//                                 .read<DoctorBloc>()
//                                 .add(RetryLoadDoctorsEvent());
//                           },
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (state is DoctorLoaded) {
//                   final doctors = state.doctors;

//                   if (doctors.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.person_search,
//                               size: 80, color: Colors.grey[400]),
//                           const SizedBox(height: 16),
//                           Text(
//                             state.searchQuery.isNotEmpty
//                                 ? 'No doctors found'
//                                 : 'No doctors available in this category',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: doctors.length,
//                     itemBuilder: (context, index) {
//                       final doctor = doctors[index];
//                       return CategoryDoctorCard(doctor: doctor);
//                     },
//                   );
//                 }

//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CategorySearchBar extends StatelessWidget {
//   const CategorySearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DoctorBloc, DoctorState>(
//       builder: (context, state) {
//         final searchQuery = state is DoctorLoaded ? state.searchQuery : '';

//         return Container(
//           color: Colors.white,
//           padding: const EdgeInsets.all(16),
//           child: TextField(
//             key: ValueKey(searchQuery),
//             controller: TextEditingController(text: searchQuery)
//               ..selection = TextSelection.collapsed(offset: searchQuery.length),
//             onChanged: (value) {
//               context.read<DoctorBloc>().add(SearchDoctorsEvent(value));
//             },
//             decoration: InputDecoration(
//               hintText: 'Search doctors...',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: searchQuery.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         context.read<DoctorBloc>().add(ResetSearchEvent());
//                       },
//                     )
//                   : null,
//               filled: true,
//               fillColor: const Color(0xFFE6EFF9),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class CategoryDoctorCard extends StatelessWidget {
//   final dynamic doctor;

//   const CategoryDoctorCard({
//     super.key,
//     required this.doctor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DoctorDetailScreen(doctorId: doctor.id!),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
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
//         child: Row(
//           children: [
//             // Doctor Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: CachedNetworkImage(
//                 imageUrl: doctor.profileImageUrl ?? '',
//                 width: 80,
//                 height: 80,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   width: 80,
//                   height: 80,
//                   color: Colors.grey[200],
//                   child: const Center(
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   width: 80,
//                   height: 80,
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.person, size: 40, color: Colors.grey),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),

//             // Doctor Info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     doctor.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     doctor.specialist,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.location_on,
//                           size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 4),
//                       Text(
//                         doctor.place,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Icon(Icons.work_outline,
//                           size: 14, color: Colors.grey[500]),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${doctor.experience} yrs',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Arrow Icon
//             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }