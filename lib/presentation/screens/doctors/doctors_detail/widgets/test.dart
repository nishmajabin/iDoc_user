// import 'package:flutter/material.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';

// class DoctorAboutSection extends StatelessWidget {
//   final String bio;

//   const DoctorAboutSection({
//     super.key,
//     required this.bio,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SectionTitle(title: 'About'),
//         const SizedBox(height: 12),
//         Text(
//           bio,
//           style: TextStyle(
//             fontSize: 14,
//             height: 1.6,
//             color: Colors.grey[700],
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:idoc_user/core/constants/color.dart';
// import 'package:idoc_user/data/models/doctor_model.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';

// class DoctorContactSection extends StatelessWidget {
//   final DoctorModel doctor;

//   const DoctorContactSection({
//     super.key,
//     required this.doctor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SectionTitle(title: 'Contact Information'),
//         const SizedBox(height: 16),
//         ContactItem(
//           icon: Icons.phone_outlined,
//           label: 'Phone',
//           value: doctor.phone,
//         ),
//         const SizedBox(height: 12),
//         ContactItem(
//           icon: Icons.email_outlined,
//           label: 'Email',
//           value: doctor.email,
//         ),
//       ],
//     );
//   }
// }

// class ContactItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const ContactItem({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE6EFF9),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           _ContactIconContainer(icon: icon),
//           const SizedBox(width: 16),
//           Expanded(
//             child: _ContactInfo(label: label, value: value),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ContactIconContainer extends StatelessWidget {
//   final IconData icon;

//   const _ContactIconContainer({required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Icon(icon, color: AppColors.primaryColor, size: 24),
//     );
//   }
// }

// class _ContactInfo extends StatelessWidget {
//   final String label;
//   final String value;

//   const _ContactInfo({
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:idoc_user/core/constants/color.dart';
// import 'package:idoc_user/data/models/doctor_model.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/book_appointment_button.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_about_section.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_contact_section.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_header.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_info_section.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_license_section.dart';

// class DoctorDetailContent extends StatelessWidget {
//   final DoctorModel doctor;

//   const DoctorDetailContent({
//     super.key,
//     required this.doctor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         DoctorHeader(doctor: doctor),
//         SliverToBoxAdapter(
//           child: _DoctorDetailsBody(doctor: doctor),
//         ),
//       ],
//     );
//   }
// }

// class _DoctorDetailsBody extends StatelessWidget {
//   final DoctorModel doctor;

//   const _DoctorDetailsBody({required this.doctor});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(30),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _DoctorNameAndSpecialty(doctor: doctor),
//             const SizedBox(height: 24),
//             DoctorInfoSection(doctor: doctor),
//             const SizedBox(height: 32),
//             DoctorAboutSection(bio: doctor.bio),
//             const SizedBox(height: 32),
//             DoctorContactSection(doctor: doctor),
//             const SizedBox(height: 32),
//             DoctorLicenseSection(licenseNumber: doctor.licenseNumber),
//             const SizedBox(height: 32),
//              BookAppointmentButton(
//               doctorId: doctor.id ?? '', 
//               doctorName: doctor.name,
//               doctorSpecialist: doctor.specialist,
//               doctorProfileImageUrl: doctor.profileImageUrl,
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DoctorNameAndSpecialty extends StatelessWidget {
//   final DoctorModel doctor;

//   const _DoctorNameAndSpecialty({required this.doctor});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           doctor.name,
//           style: const TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           doctor.specialist,
//           style: TextStyle(
//             fontSize: 16,
//             color: AppColors.primaryColor,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:idoc_user/data/models/doctor_model.dart';

// class DoctorHeader extends StatelessWidget {
//   final DoctorModel doctor;

//   const DoctorHeader({
//     super.key,
//     required this.doctor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       backgroundColor: Colors.white,
//       leading: _BackButton(),
//       flexibleSpace: FlexibleSpaceBar(
//         background: _DoctorProfileImage(imageUrl: doctor.profileImageUrl),
//       ),
//     );
//   }
// }

// class _BackButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//         child: const Icon(Icons.arrow_back, color: Colors.black87),
//       ),
//       onPressed: () => Navigator.pop(context),
//     );
//   }
// }

// class _DoctorProfileImage extends StatelessWidget {
//   final String? imageUrl;

//   const _DoctorProfileImage({required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl ?? '',
//       fit: BoxFit.cover,
//       placeholder: (context, url) => Container(
//         color: Colors.grey[200],
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//       errorWidget: (context, url, error) => Container(
//         color: Colors.grey[200],
//         child: const Icon(Icons.person, size: 100, color: Colors.grey),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/common/section_title.dart';
// import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/doctor_contact_section.dart';

// class DoctorLicenseSection extends StatelessWidget {
//   final String licenseNumber;

//   const DoctorLicenseSection({
//     super.key,
//     required this.licenseNumber,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SectionTitle(title: 'License Information'),
//         const SizedBox(height: 16),
//         ContactItem(
//           icon: Icons.badge_outlined,
//           label: 'License Number',
//           value: licenseNumber,
//         ),
//       ],
//     );
//   }
// }