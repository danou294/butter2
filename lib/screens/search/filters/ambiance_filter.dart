import 'package:flutter/material.dart';

// Map publique pour la correspondance ambiance clé <-> valeur
const Map<String, String> ambianceKeyToValue = {
  'Intimiste': 'Intimiste',
  'Classique': 'Classique',
  'Festif': 'Festif',
};

/// Composant de filtre "Ambiance" pour les restaurants.
/// Affiche une série de chips représentant l'ambiance souhaitée.
/// Sélection multiple possible.
///
/// - [selected] : ensemble des clés Firestore actuellement sélectionnées.
/// - [onToggle] : callback appelé lors de la sélection ou désélection d'une clé.
class AmbianceFilterPage extends StatelessWidget {
  final Set<String> selected;
  final void Function(String key, bool selected) onToggle;

  const AmbianceFilterPage({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PremiumBlockWidget(
      onUpgrade: () {
        Navigator.pushNamed(context, '/paiement');
      },
    );
  }
}

class _PremiumBlockWidget extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _PremiumBlockWidget({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 48, color: Colors.black54),
          const SizedBox(height: 16),
          Text(
            "Cette fonctionnalité est réservée aux membres Butter Premium.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Rejoins-nous pour y avoir accès !",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Upgrade"),
          ),
        ],
      ),
    );
  }
}
