import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'registration_page.dart';
import 'login_page.dart';

class WelcomeLanding extends StatelessWidget {
  const WelcomeLanding({super.key});

  void _signInAnonymously(BuildContext context) async {
    try {
      await AuthService().signInAnonymously();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la connexion invitée : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final logoWidth = isTablet ? 240.0 : 180.0;
          final textFontSize = isTablet ? 18.0 : 14.0;
          final buttonPadding = isTablet ? 20.0 : 16.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/background-app.png',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.45),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // 🧈 Logo BUTTER
                      Image.asset(
                        'assets/images/LogoName.png',
                        width: logoWidth,
                      ),

                      // ✨ Tagline espacée
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Food, drinks',
                            style: TextStyle(
                              fontFamily: 'InriaSans',
                              fontWeight: FontWeight.bold,
                              fontSize: textFontSize,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            ' ',
                            style: TextStyle(
                              fontFamily: 'InriaSans',
                              fontWeight: FontWeight.bold,
                              fontSize: textFontSize,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Text(
                            'and vibe',
                            style: TextStyle(
                              fontFamily: 'InriaSans',
                              fontWeight: FontWeight.bold,
                              fontSize: textFontSize,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // 🔽 Bas de l’écran
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ Devenir membre
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                                textStyle: const TextStyle(
                                  fontFamily: 'InriaSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegistrationPage()),
                                );
                              },
                              child: const Text('Devenir membre'),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ✅ Connexion anonyme
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                                textStyle: const TextStyle(
                                  fontFamily: 'InriaSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _signInAnonymously(context),
                              child: const Text('Continuer en tant qu’invité'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔗 Se connecter
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            },
                            child: Text(
                              'Déjà membre ? Se connecter',
                              style: TextStyle(
                                fontFamily: 'InriaSans',
                                fontSize: isTablet ? 15 : 13,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 📝 Disclaimer
                          Text(
                            'En tapant sur “Devenir membre” ou “Continuer en tant qu’invité”\n'
                            'tu acceptes nos conditions d’utilisation et politique de confidentialité',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: isTablet ? 12 : 10,
                              color: Colors.white54,
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}