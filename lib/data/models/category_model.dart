

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CategoryModel(
      id: docId,
      name: data['name'] ?? '',
      imageUrl: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': imageUrl,
    };
  }
}