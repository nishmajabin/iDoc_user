
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/doctor_detail_screen.dart';

Widget buildDoctorCard(DoctorModel doctor) {
  return Builder(
    builder: (context) {
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
          width: 150,
          height: 165,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 246, 251, 255),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.46),
                blurRadius: 4,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl: doctor.profileImageUrl ?? '',
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        height: 100,
                        color: const Color.fromARGB(255, 178, 178, 178),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),

              // Doctor Info - FIXED LAYOUT
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Specialist and Experience in same row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.specialist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.work_rounded,
                          size: 15,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${doctor.experience}yr',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}