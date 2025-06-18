import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/main_navigation.dart';    // Onglets de navigation principale
import 'screens/welcome_landing.dart';    // Page d'accueil (non connecté)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          // ✅ Utilisateur connecté (authentifié)
          return const MainNavigation();
        } else {
          // ❌ Aucun utilisateur → page d'accueil avec options de connexion
          return const WelcomeLanding();
        }
      },
    );
  }
}
