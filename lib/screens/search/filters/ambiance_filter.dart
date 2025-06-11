import 'package:flutter/material.dart';

/// Composant de filtre "Ambiance" pour les restaurants.
/// Affiche une série de chips représentant l'ambiance souhaitée.
/// Sélection multiple possible.
///
/// - [selected] : ensemble des clés Firestore actuellement sélectionnées.
/// - [onToggle] : callback appelé lors de la sélection ou désélection d'une clé.
class AmbianceFilter extends StatelessWidget {
  /// Ensemble des clés Firestore sélectionnées (ex. 'ambiance_classique').
  final Set<String> selected;

  /// Fonction appelée lors du basculement d'un filtre.
  /// - [key]     : clé Firestore de l'ambiance.
  /// - [selected]: nouvel état (true = sélectionné).
  final void Function(String key, bool selected) onToggle;

  const AmbianceFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  // Mapping affichage → clé Firestore et valeur technique
  static const Map<String, String> _labelToKey = {
    'Classique':       'ambiance_classique',
    'Intimiste/tamisé':'ambiance_intimiste',
    'Festif':          'ambiance_festif',
    'Date':            'ambiance_date',
  };
  static const Map<String, String> keyToValue = {
    'ambiance_classique': 'Classique',
    'ambiance_intimiste': 'Intimiste',
    'ambiance_festif':    'Festif',
    'ambiance_date':      'Date',
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
    final value = keyToValue[key]!;
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
