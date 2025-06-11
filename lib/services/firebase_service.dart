import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../firebase_options.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
        if (kDebugMode) {
          print('⚠️ Firebase déjà initialisé, on ignore cette erreur.');
        }
      } else {
        rethrow; // on relance si c'est une autre erreur
      }
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    _initialized = true;
  }
}
