import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/call/screens/incoming_call/widgets/incoming_call_fall_back_avatar.dart';

class IncomingCallDoctorAvatar extends StatelessWidget {
  final String doctorName;
  final String? doctorProfileImageUrl;

  const IncomingCallDoctorAvatar({
    required this.doctorName,
    required this.doctorProfileImageUrl,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: _avatarContent(),
      ),
    );
  }

  Widget _avatarContent() {
    final url = doctorProfileImageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => IncomingCallFallBackAvatar(doctorName: doctorName),
      );
    }
    return IncomingCallFallBackAvatar(doctorName: doctorName);
  }
}
