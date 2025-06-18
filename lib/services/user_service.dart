import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Vérifie si un utilisateur existe dans Firestore via son UID
  Future<bool> userExists(String uid) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Récupère un utilisateur Firestore par son numéro de téléphone
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }

    return null;
  }

  /// Crée un nouvel utilisateur Firestore
  Future<void> createUser({
    required String uid,
    required String phone,
    required String prenom,
    required String dateNaissance,
  }) async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'phone': phone,
      'prenom': prenom.trim(),
      'dateNaissance': dateNaissance,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère le prénom de l'utilisateur actuellement connecté
  Future<String?> fetchCurrentUserPrenom() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['prenom'];
  }

  /// Récupère toutes les données de l'utilisateur actuellement connecté
  Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
