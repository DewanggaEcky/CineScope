import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference? get _favouriteCollection {
    final userId = currentUserId;
    if (userId == null) return null;

    return _db.collection('users').doc(userId).collection('favorites');
  }

  Future<List<String>> getFavouriteIds() async {
    final collection = _favouriteCollection;
    if (collection == null) return [];

    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching favorite IDs from Firestore: $e");
      return [];
    }
  }

  Future<void> addFavourite(String movieId) async {
    final collection = _favouriteCollection;
    if (collection == null) return;

    await collection.doc(movieId).set({
      'isFavorite': true,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavourite(String movieId) async {
    final collection = _favouriteCollection;
    if (collection == null) return;

    await collection.doc(movieId).delete();
  }

  Future<bool> isFavourite(String movieId) async {
    final collection = _favouriteCollection;
    if (collection == null) return false;

    final doc = await collection.doc(movieId).get();
    return doc.exists;
  }
}