import 'dart:async';
import 'package:flutter/material.dart';

class SplashCarouselPage extends StatefulWidget {
  const SplashCarouselPage({super.key});

  @override
  State<SplashCarouselPage> createState() => _SplashCarouselPageState();
}

class _SplashCarouselPageState extends State<SplashCarouselPage> {
  final List<String> _imagePaths = [
    'assets/images/home_1.png',
    'assets/images/home_2.png',
    'assets/images/home_3.png',
    'assets/images/background-app.png',
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    print('✅ SplashCarouselPage initState');
    print('🔁 Démarrage du timer pour changement d’image toutes les 3 secondes.');

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imagePaths.length;
        print('➡️ Image changée : index $_currentIndex -> ${_imagePaths[_currentIndex]}');
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    print('🛑 Timer annulé dans dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 📸 Images en fondu
          ..._imagePaths.asMap().entries.map((entry) {
            int index = entry.key;
            String path = entry.value;
            return AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: index == _currentIndex ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Erreur de chargement image : $path');
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.red, size: 60),
                  );
                },
              ),
            );
          }).toList(),

          // 🧊 Pellicule noire semi-transparente
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // 🧈 Logo centré
          Center(
            child: Image.asset(
              'assets/images/LogoName.png',
              width: 160,
              errorBuilder: (context, error, stackTrace) {
                print('❌ Erreur de chargement du logo !');
                return const Text('Logo manquant', style: TextStyle(color: Colors.red));
              },
            ),
          ),
        ],
      ),
    );
  }
}
