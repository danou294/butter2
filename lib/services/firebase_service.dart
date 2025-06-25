import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../firebase_options.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) print('🔄 Firebase déjà initialisé, on saute.');
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        print('🚀 Initialisation de Firebase avec les options par défaut...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase initialisé.');
      } else {
        print('📦 Firebase déjà initialisé (detected ${Firebase.apps.length} apps).');
      }
    } catch (e) {
      if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
        print('⚠️ Firebase "[DEFAULT]" déjà initialisé → on continue.');
      } else {
        print('❌ Erreur pendant Firebase.initializeApp() : $e');
        rethrow;
      }
    }

    try {
      print('🛡️ Activation de Firebase App Check (mode debug)...');
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      print('✅ App Check activé.');
    } catch (e) {
      print('❌ Erreur pendant l\'activation de Firebase App Check : $e');
    }

    // Log des apps actives
    for (final app in Firebase.apps) {
      print('📲 FirebaseApp: ${app.name} | ID: ${app.options.appId}');
    }

    _initialized = true;
  }
}