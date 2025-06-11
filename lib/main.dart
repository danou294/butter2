import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'services/firebase_service.dart'; // <-- Le service Firebase centralisé
import 'auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation de Firebase (Core + configurations custom)
  await FirebaseService.initialize();

  // Activation d'App Check en mode debug pour Android et iOS (émulateur ou device dev)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug, // Active aussi pour iOS
    webProvider: null, // Laisse null sauf si tu fais du web
  );
  // Après lancement, copie le token debug affiché dans les logs et ajoute-le dans la console Firebase > App Check > Debug tokens.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      home: const AuthGate(),
    );
  }
}
