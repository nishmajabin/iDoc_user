import 'package:flutter/material.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback? onEditPressed;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer ring
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6AD2FF),
                Color(0xFF0096C7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4D8).withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: Stack(
                children: [
                  _buildImage(),
                  if (isUploading) _buildUploadOverlay(),
                ],
              ),
            ),
          ),
        ),

        // Edit button
        if (onEditPressed != null && !isUploading)
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00B4D8),
                      Color(0xFF0096C7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0096C7).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: 106,
        height: 106,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildImageLoading(progress);
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 106,
      height: 106,
      color: const Color(0xFFE8F4FD),
      child: const Icon(
        Icons.person_rounded,
        size: 54,
        color: Color(0xFF90E0EF),
      ),
    );
  }

  Widget _buildImageLoading(ImageChunkEvent progress) {
    return Container(
      width: 106,
      height: 106,
      color: const Color(0xFFE8F4FD),
      child: Center(
        child: CircularProgressIndicator(
          value: progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
              : null,
          color: const Color(0xFF00B4D8),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return Container(
      width: 106,
      height: 106,
      color: Colors.black.withOpacity(0.55),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              value: uploadProgress,
              color: Colors.white,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${(uploadProgress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}