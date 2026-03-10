import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String? id;
  final String doctorId;
  final String userId;
  final double rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RatingModel({
    this.id,
    required this.doctorId,
    required this.userId,
    required this.rating,
    this.review,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RatingModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      review: map['review'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  RatingModel copyWith({
    String? id,
    String? doctorId,
    String? userId,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}