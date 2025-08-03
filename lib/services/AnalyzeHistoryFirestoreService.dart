import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/AnalyzeHistoryEntry.dart';

class AnalyzeHistoryFirestoreService {
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  Future<void> saveEntry(AnalyzeHistoryEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in!");
    final uid = user.uid;
    await db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add(entry.toJson());
  }

  Future<List<AnalyzeHistoryEntry>> fetchEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in!");
    final uid = user.uid; // <-- stocké en non-nullable ici

    final snap = await db
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('analyzedAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => AnalyzeHistoryEntry.fromJson(doc.data()))
        .toList();
  }
}