import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/firebase_service.dart';
import 'services/purchase_service.dart';
import 'auth_gate.dart';

void main() async {
  // ✅ Ce bloc garantit que le binding et runApp sont dans la même zone
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Environnement d'exécution sécurisé
  runZonedGuarded(() async {
    print('🚀 Initialisation Firebase...');
    await FirebaseService.initialize();

    print('💸 Initialisation des achats in-app...');
    await PurchaseService().initialize();

    print('✅ Lancement de l’application...');
    runApp(const MyApp());
  }, (error, stack) {
    print('🔥 Erreur asynchrone non capturée : $error');
    print('↪️ Stacktrace : $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Butter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
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