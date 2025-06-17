import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final bool isSubscribed;
  final bool isAnonymous;

  const AmbianceFilterPage({
    Key? key,
    required this.selected,
    required this.onToggle,
    required this.isSubscribed,
    required this.isAnonymous,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isSubscribed || isAnonymous) {
      return _PremiumBlockWidget(
        onUpgrade: () {
          Navigator.pushNamed(context, '/paiement');
        },
        isAnonymous: isAnonymous,
      );
    }
    return _AmbianceFilter(
      selected: selected,
      onToggle: onToggle,
    );
  }
}

class _PremiumBlockWidget extends StatelessWidget {
  final VoidCallback onUpgrade;
  final bool isAnonymous;

  const _PremiumBlockWidget({required this.onUpgrade, required this.isAnonymous});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 48, color: Colors.black54),
          const SizedBox(height: 16),
          Text(
            isAnonymous
                ? "Connecte-toi ou crée un compte pour accéder à cette fonctionnalité."
                : "Cette fonctionnalité est réservée aux membres Butter Premium.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isAnonymous
                ? "Identifie-toi pour profiter de toutes les fonctionnalités."
                : "Rejoins-nous pour y avoir accès !",
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
            child: Text(isAnonymous ? "Se connecter" : "Upgrade"),
          ),
        ],
      ),
    );
  }
}

class _AmbianceFilter extends StatelessWidget {
  final Set<String> selected;
  final void Function(String key, bool selected) onToggle;

  const _AmbianceFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  // Mapping affichage → clé Firestore et valeur technique
  static const Map<String, String> _labelToKey = {
    'Intimiste': 'Intimiste',
    'Classique': 'Classique',
    'Festif': 'Festif',
  };

  // Styles des chips (identiques à MomentFilter/CuisineFilter)
  static const Color _selectedBg   = Color(0xFFBFB9A4);
  static const Color _unselectedBg = Color(0xFFF5F5F0);
  static const Color _labelColor   = Colors.black;
  static const String _fontFamily  = 'InriaSans';
  static const double _chipHeight  = 32.0;
  static const double _hPadding    = 12.0;
  static const double _vPadding    = 8.0;
  static const double _spacing     = 8.0;
  static const double _fontSize    = 14.0;

  Widget _buildChip(String label) {
    final key = _labelToKey[label]!;
    final value = ambianceKeyToValue[key]!;
    final isSelected = selected.contains(value);

    return InkWell(
      onTap: () => onToggle(value, !isSelected),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: _chipHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: _hPadding,
          vertical: _vPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : _unselectedBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: _fontSize,
            color: _labelColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labelToKey.keys.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Wrap(
        spacing: _spacing,
        runSpacing: _spacing,
        alignment: WrapAlignment.center,
        children: labels.map(_buildChip).toList(),
      ),
    );
  }
}
