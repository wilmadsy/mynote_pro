import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 GET NOTES (REALTIME)
  Stream<QuerySnapshot> getNotes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🔹 ADD NOTE
  Future<void> addNote(String userId, String title, String description) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  // 🔹 DELETE NOTE
  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}