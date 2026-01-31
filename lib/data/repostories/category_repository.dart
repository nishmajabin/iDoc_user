
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Load all categories from Firestore
  Future<List<CategoryModel>> loadCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }

  /// Stream categories for real-time updates
  Stream<List<CategoryModel>> categoriesStream() {
    return _firestore.collection('categories').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }
}