import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_state.dart';

class DoctorHeader extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorHeader({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: _BackButton(),
      actions: [
        BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            final isFav = state.isFavorite(doctor.id ?? '');
            return Container(
               margin: const EdgeInsets.only(right: 8),
               decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black87,
                ),
                onPressed: () {
                  if (doctor.id != null) {
                    context.read<FavoritesBloc>().add(ToggleFavorite(doctor.id!));
                  }
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _DoctorProfileImage(imageUrl: doctor.profileImageUrl),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }
}

class _DoctorProfileImage extends StatelessWidget {
  final String? imageUrl;

  const _DoctorProfileImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.person, size: 100, color: Colors.grey),
      ),
    );
  }
}