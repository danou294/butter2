import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/main_navigation.dart';    // Onglets de navigation principale
import 'screens/welcome_landing.dart';    // Page d'accueil (non connecté)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _ensureAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
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
              // ✅ Utilisateur connecté (anonyme ou authentifié)
              return const MainNavigation();
            } else {
              // ❌ Aucun utilisateur → page d'accueil
              return const WelcomeLanding();
            }
          },
        );
      },
    );
  }

  Future<void> _ensureAuth() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }
}
