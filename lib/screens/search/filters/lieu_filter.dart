import 'package:flutter/material.dart';

/// Composant de filtre "Lieu" pour les restaurants.
/// Affiche une série de chips représentant le contexte de lieu.
/// Sélection multiple possible, chaque chip correspond à une clé Firestore.
///
/// - [selected] : ensemble des clés de lieu actuellement sélectionnées.
/// - [onToggle] : callback appelé lors de la sélection ou désélection d'une clé.
class LieuFilter extends StatelessWidget {
  /// Ensemble des clés Firestore sélectionnées (ex. 'dans_la_rue', 'dans_un_musee').
  final Set<String> selected;

  /// Fonction appelée lors du basculement d'un filtre.
  /// - [key]     : clé Firestore du lieu.
  /// - [selected]: nouvel état (true = sélectionné).
  final void Function(String key, bool selected) onToggle;

  const LieuFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  // Mapping affichage → clé Firestore
  static const Map<String, String> labelToKey = {
    'Dans la rue':        'Dans la rue',
    'Dans une galerie':   'Dans une galerie',
    'Dans un musée':      'Dans un musée',
    'Dans un monument':   'Dans un monument',
    'Dans un hôtel':      'Dans un hôtel',
    'Other':              'Other',
  };

  // Styles des chips, alignés sur MomentFilter
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
    final labels = labelToKey.keys.toList();
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