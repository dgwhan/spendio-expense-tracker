import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<void> saveCustomCategory(String remoteUid, CategoryModel category);

  Future<void> removeCustomCategory(String remoteUid, String categoryId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> saveCustomCategory(
      String remoteUid, CategoryModel category) async {
    // Reference path: users/{remoteUid}/custom_categories/{categoryId}
    final DocumentReference categoryDoc = firestore
        .collection('users')
        .doc(remoteUid)
        .collection('custom_categories')
        .doc(category.id);

    // Write data to Firestore container using the model's Map conversion logic
    await categoryDoc.set(
      category.toMap(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> removeCustomCategory(String remoteUid, String categoryId) async {
    // Reference path: users/{remoteUid}/custom_categories/{categoryId}
    final DocumentReference categoryDoc = firestore
        .collection('users')
        .doc(remoteUid)
        .collection('custom_categories')
        .doc(categoryId);

    await categoryDoc.delete();
  }
}
