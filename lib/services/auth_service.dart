import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Envoie un code OTP au numéro fourni
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    print('📞 [verifyPhoneNumber] Début de la vérification du numéro $phoneNumber');

    // 🔒 Défense contre crash iOS : s'assurer que FirebaseAuth est bien initialisé
    if (_auth.app == null) {
      print('❌ [verifyPhoneNumber] FirebaseAuth.instance.app est NULL ❗');
      onVerificationFailed(
        FirebaseAuthException(
          code: 'auth-not-initialized',
          message: 'FirebaseAuth.instance n\'est pas correctement initialisé.',
        ),
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) {
          print('✅ [verifyPhoneNumber] Vérification automatique réussie');
          onVerificationCompleted(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ [verifyPhoneNumber] Échec de la vérification');
          print('↪️ Code : ${e.code}');
          print('↪️ Message : ${e.message}');
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('📨 [verifyPhoneNumber] Code envoyé');
          print('↪️ verificationId : $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ [verifyPhoneNumber] Timeout auto');
          print('↪️ verificationId : $verificationId');
        },
        forceResendingToken: null,
        multiFactorSession: null,
      );
    } catch (e) {
      print('❌ [verifyPhoneNumber] Erreur inattendue : $e');
      rethrow;
    }
  }

  /// Vérifie l'OTP saisi manuellement
  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    print('🔐 [AuthService] Tentative de connexion avec OTP');
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      print('✅ [AuthService] Connexion réussie avec OTP');
    } catch (e) {
      print('❌ [AuthService] Erreur OTP : $e');
      rethrow;
    }
  }

  /// Connexion automatique avec credential (ex: Android auto verify)
  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    print('🔑 [AuthService] Connexion avec credential');
    try {
      await _auth.signInWithCredential(credential);
      print('✅ [AuthService] Connexion réussie');
    } catch (e) {
      print('❌ [AuthService] Erreur credential : $e');
      rethrow;
    }
  }

  /// Connexion anonyme
  Future<void> signInAnonymously() async {
    print('👤 [AuthService] Connexion anonyme');
    try {
      await _auth.signInAnonymously();
      print('✅ [AuthService] Connexion anonyme réussie');
    } catch (e) {
      print('❌ [AuthService] Erreur anonyme : $e');
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    print('🚪 [AuthService] Déconnexion');
    try {
      await _auth.signOut();
      print('✅ [AuthService] Déconnexion réussie');
    } catch (e) {
      print('❌ [AuthService] Erreur déconnexion : $e');
      rethrow;
    }
  }

  /// Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Écoute les changements d'état
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}