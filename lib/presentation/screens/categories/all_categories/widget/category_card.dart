
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/categories/category_doctors/category_doctors_screen.dart';

class CategoryCard extends StatelessWidget {
  final dynamic category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDoctors(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CategoryImage(imageUrl: category.imageUrl),
            const SizedBox(height: 10),
            _CategoryName(name: category.name),
          ],
        ),
      ),
    );
  }

  void _navigateToDoctors(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDoctorsScreen(
          categoryName: category.name,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final String imageUrl;

  const _CategoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      placeholder: (context, url) => const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.medical_services,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

class _CategoryName extends StatelessWidget {
  final String name;

  const _CategoryName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}