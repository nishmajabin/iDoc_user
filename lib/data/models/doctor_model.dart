import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String? id;
  final String name;
  final String place;
  final String email;
  final String password;
  final String? confirmPassword;
  final String phone;
  final String gender;
  final String specialist;
  final String bio;
  final String licenseNumber;
  final int experience;
  final String? licenseProofUrl;
  final String? profileImageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double averageRating;
  final int totalRatings;
  final double consultationFee;

  DoctorModel({
    this.id,
    required this.name,
    required this.place,
    required this.email,
    required this.password,
    this.confirmPassword,
    required this.phone,
    required this.gender,
    required this.specialist,
    required this.bio,
    required this.licenseNumber,
    required this.experience,
    this.licenseProofUrl,
    this.profileImageUrl,
    this.status = 'pending',
    DateTime? createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.consultationFee = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'place': place,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'specialist': specialist,
      'bio': bio,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'licenseProofUrl': licenseProofUrl,
      'profileImageUrl': profileImageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'consultationFee': consultationFee,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DoctorModel(
      id: documentId,
      name: map['name'] ?? '',
      place: map['place'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      specialist: map['specialist'] ?? '',
      bio: map['bio'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      experience: map['experience'] ?? 0,
      licenseProofUrl: map['licenseProofUrl'],
      profileImageUrl: map['profileImageUrl'],
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(), 
    );
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? place,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? gender,
    String? specialist,
    String? bio,
    String? licenseNumber,
    int? experience,
    String? licenseProofUrl,
    String? profileImageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    int? totalRatings,
    double? consultationFee,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      specialist: specialist ?? this.specialist,
      bio: bio ?? this.bio,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experience: experience ?? this.experience,
      licenseProofUrl: licenseProofUrl ?? this.licenseProofUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      consultationFee: consultationFee ?? this.consultationFee,
    );
  }

  bool validatePasswords() {
    return confirmPassword != null && password == confirmPassword;
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialist: $specialist, fee: ₹$consultationFee)';
  }
}