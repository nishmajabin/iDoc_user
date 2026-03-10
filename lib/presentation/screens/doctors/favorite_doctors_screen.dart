
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_state.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

class FavoriteDoctorsScreen extends StatelessWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Doctors', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFE6EFF9),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoriteStatus.loading && state.favoriteDoctors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.favoriteDoctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite doctors yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Adjusted for card height
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.favoriteDoctors.length,
            itemBuilder: (context, index) {
              return _FavoriteDoctorCard(doctor: state.favoriteDoctors[index]);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _FavoriteDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(doctorId: doctor.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: doctor.profileImageUrl ?? '',
                  height: 120, // Specific height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.grey[200],
                     child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          if (doctor.totalRatings > 0)
                            Row(
                              children: [
                                Text(
                                  doctor.averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialist,
                       maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                     const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.work_rounded, size: 14, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text('${doctor.experience}yr', style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
