import 'package:flutter/material.dart';

/// Composant de filtre "Moment" pour les restaurants.
/// Affiche une série de chips représentant les moments de la journée.
/// Sélection multiple possible, chaque chip applique un ou plusieurs filtres Firestore.
///
/// - [selected] : ensemble des clés de moments actuellement sélectionnées.
/// - [onToggle] : callback appelé lors de la sélection ou désélection d'une clé.
class MomentFilter extends StatelessWidget {
  /// Ensemble des clés Firestore sélectionnées (ex. 'petit_dejeuner', 'dejeuner').
  final Set<String> selected;

  /// Fonction appelée lors du basculement d'un filtre.
  /// - [key]     : clé Firestore du moment.
  /// - [selected]: nouvel état (true = sélectionné).
  final void Function(String key, bool selected) onToggle;

  const MomentFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  // Couleurs et style des chips
  static const Color _selectedBg     = Color(0xFFBFB9A4);
  static const Color _unselectedBg   = Color(0xFFF5F5F0);
  static const Color _labelColor     = Colors.black;
  static const String _fontFamily    = 'InriaSans';
  static const double _chipHeight    = 32.0;
  static const double _hPadding      = 12.0;
  static const double _vPadding      = 8.0;
  static const double _spacing       = 8.0;
  static const double _fontSize      = 14.0;

  /// Mapping affichage → clés Firestore.
  /// "Brunch" coche toutes les clés brunch_*. Pas de chip séparé pour samedi/dimanche.
  static const Map<String, String> labelToKey = {
    'Petit-déjeuner': 'Petit-déjeuner',
    'Brunch': 'Brunch',
    'Déjeuner': 'Déjeuner',
    'Goûter': 'Goûter',
    'Drinks': 'Drinks',
    'Dîner': 'Dîner',
    'Apéro': 'Apéro',
    'Brunch le samedi': 'Brunch le samedi',
    'Brunch le dimanche': 'Brunch le dimanche',
  };

  Widget _buildChip(String label) {
    final key = labelToKey[label]!;
    final isSelected = selected.contains(key);

    return InkWell(
      onTap: () => onToggle(key, !isSelected),
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
    // Liste des libellés affichés
    const labels = [
      'Petit-déjeuner',
      'Brunch',
      'Déjeuner',
      'Goûter',
      'Drinks',
      'Dîner',
      'Apéro',
      'Brunch le samedi',
      'Brunch le dimanche',
    ];

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
