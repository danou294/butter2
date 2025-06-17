// lib/screens/search/filters/restrictions_filter.dart

import 'package:flutter/material.dart';

/// Composant de filtre "Restrictions" pour les restaurants.
/// Affiche une série de chips représentant les restrictions alimentaires.
/// Sélection multiple possible.
///
/// - [selected] : ensemble des clés Firestore actuellement sélectionnées.
/// - [onToggle] : callback appelé lors de la sélection ou désélection d'une clé.
class RestrictionsFilter extends StatelessWidget {
  /// Ensemble des clés Firestore sélectionnées (ex. 'Casher (certifié)', 'Végétarien').
  final Set<String> selected;

  /// Fonction appelée lors du basculement d'un filtre.
  /// - [key]     : clé Firestore de la restriction.
  /// - [selected]: nouvel état (true = sélectionné).
  final void Function(String key, bool selected) onToggle;

  const RestrictionsFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  // Mapping affichage → clé Firestore
  static const Map<String, String> _labelToKey = {
    'Casher': 'Casher (certifié)',
    'Végétarien': 'Végétarien',
  };

  // Liste des libellés affichés
  static const List<String> _labels = [
    'Casher',
    'Végétarien',
  ];

  // Styles des chips (identiques aux autres filtres)
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
    final isSelected = selected.contains(key);

    return GestureDetector(
      onTap: () => onToggle(key, !isSelected),
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
          textAlign: TextAlign.center,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        spacing: _spacing,
        runSpacing: _spacing,
        alignment: WrapAlignment.center,
        children: _labels.map(_buildChip).toList(),
      ),
    );
  }
}
