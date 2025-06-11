import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Envoie un code OTP au numéro fourni
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Vérifie l'OTP saisi manuellement
  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  /// Connexion auto avec credential (Android only)
  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    await _auth.signInWithCredential(credential);
  }

  /// Connexion anonyme
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Écouter les changements d'état de connexion
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
