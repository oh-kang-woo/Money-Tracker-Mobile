import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/constants/firebase_collections.dart';
import '../models/category_model.dart';

class CategoryController {
  final CollectionReference _catRef =
      FirebaseFirestore.instance.collection(FirebaseCollections.categories);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addCategory(CategoryModel category) async {
    await _catRef.add(category.toMap());
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    if (_uid == null) return Stream.value([]);
    return _catRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> deleteCategory(String id) async {
    await _catRef.doc(id).delete();
  }
}