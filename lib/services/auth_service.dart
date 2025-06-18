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
    print('📞 [verifyPhoneNumber] Début de la vérification du numéro $phoneNumber');
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
          print('⏰ [verifyPhoneNumber] Délai de récupération automatique dépassé');
          print('↪️ verificationId : $verificationId');
        },
        forceResendingToken: null,
        multiFactorSession: null,
      );
    } catch (e) {
      print('❌ [verifyPhoneNumber] Erreur inattendue lors de la vérification: $e');
      rethrow;
    }
  }

  /// Vérifie l'OTP saisi manuellement
  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    print('🔐 AuthService: Tentative de connexion avec OTP');
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      print('✅ AuthService: Connexion réussie avec OTP');
    } catch (e) {
      print('❌ AuthService: Erreur lors de la connexion avec OTP: $e');
      rethrow;
    }
  }

  /// Connexion auto avec credential (Android only)
  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    print('🔑 AuthService: Tentative de connexion avec credential');
    try {
      await _auth.signInWithCredential(credential);
      print('✅ AuthService: Connexion réussie avec credential');
    } catch (e) {
      print('❌ AuthService: Erreur lors de la connexion avec credential: $e');
      rethrow;
    }
  }

  /// Connexion anonyme
  Future<void> signInAnonymously() async {
    print('👤 AuthService: Tentative de connexion anonyme');
    try {
      await _auth.signInAnonymously();
      print('✅ AuthService: Connexion anonyme réussie');
    } catch (e) {
      print('❌ AuthService: Erreur lors de la connexion anonyme: $e');
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    print('🚪 AuthService: Tentative de déconnexion');
    try {
      await _auth.signOut();
      print('✅ AuthService: Déconnexion réussie');
    } catch (e) {
      print('❌ AuthService: Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  /// Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Écouter les changements d'état de connexion
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
