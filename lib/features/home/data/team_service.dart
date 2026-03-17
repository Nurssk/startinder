import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> createTeam(String teamName) async {
    if (uid == null) return;

    await _firestore.collection('teams').add({
      'name': teamName,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMyTeams() {
    return _firestore
        .collection('teams')
        .where('ownerId', isEqualTo: uid)
        .snapshots();
  }
}