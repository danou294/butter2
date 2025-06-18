import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:async';

import 'services/firebase_service.dart';
import 'services/purchase_service.dart';
import 'auth_gate.dart';

// Définition des IDs des produits
const Set<String> _kIds = {'premium_monthly', 'premium_yearly'};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de la gestion des erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    print('⚠️ FlutterError: ${details.exception}');
    print('↪️ Stack: ${details.stack}');
  };

  // Gestion des erreurs asynchrones non interceptées
  runZonedGuarded(() async {
    // Initialisation de Firebase (Core + configurations custom)
    await FirebaseService.initialize();

    // Activation d'App Check en mode debug pour Android et iOS
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: null,
    );

    // Initialisation des achats in-app
    await PurchaseService().initialize();

    runApp(const MyApp());
  }, (error, stackTrace) {
    print('🔥 Uncaught async error: $error');
    print('↪️ Stacktrace: $stackTrace');
  });
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
