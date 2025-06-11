import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Vérifie si un utilisateur existe dans Firestore via son UID
  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Récupère un utilisateur Firestore par son numéro de téléphone
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
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
    print('Current user: [32m[1m[4m[7m${FirebaseAuth.instance.currentUser}[0m');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['prenom'];
  }

  /// Récupère toutes les données de l'utilisateur actuellement connecté
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
