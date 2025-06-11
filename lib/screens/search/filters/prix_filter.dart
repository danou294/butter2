// lib/screens/search/filters/prix_filter.dart

import 'package:flutter/material.dart';

// TODO : adapte ces constantes à ta charte graphique
const _trackColor = Color(0xFFF5F5F0);
const _activeColor = Color(0xFFBFB9A4);
const _thumbColor = Colors.black;
const _labelColor = Colors.black;
const _fontFamilySans = 'InriaSans';

/// Niveaux de prix (4 paliers)
const List<String> _priceLevels = ['€', '€€', '€€€', '€€€€'];

typedef OnToggle = void Function(String label, bool selected);

class PrixFilter extends StatefulWidget {
  final Set<String> selected;
  final OnToggle onToggle;

  const PrixFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<PrixFilter> createState() => _PrixFilterState();
}

class _PrixFilterState extends State<PrixFilter> {
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _syncValueWithSelected();
  }

  @override
  void didUpdateWidget(covariant PrixFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si on a supprimé la sélection, on revient à 0
    if (oldWidget.selected.contains(_currentLabel) &&
        !widget.selected.contains(_currentLabel)) {
      setState(() => _value = 0);
    }
    _syncValueWithSelected();
  }

  void _syncValueWithSelected() {
    if (widget.selected.isNotEmpty) {
      final lvl = widget.selected.first;
      final idx = _priceLevels.indexOf(lvl);
      _value = (idx >= 0 ? idx : 0).toDouble();
    } else {
      _value = 0;
    }
  }

  String get _currentLabel => _priceLevels[_value.round()];

  void _onSliderChanged(double v) {
    setState(() => _value = v);
    // désélectionne tout
    for (var lvl in _priceLevels) {
      if (widget.selected.contains(lvl)) widget.onToggle(lvl, false);
    }
    // coche le nouveau
    widget.onToggle(_currentLabel, true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // un peu plus grand
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0), // centré avec marges latérales
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slider horizontal agrandi et plus épais
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _activeColor,
                inactiveTrackColor: _trackColor,
                thumbColor: _thumbColor,
                overlayColor: _thumbColor.withOpacity(0.2),
                trackHeight: 8, // plus épais
                tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
                activeTickMarkColor: _thumbColor,
                inactiveTickMarkColor: _trackColor,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12), // plus gros
              ),
              child: Slider(
                value: _value,
                min: 0,
                max: (_priceLevels.length - 1).toDouble(),
                divisions: _priceLevels.length - 1,
                label: _currentLabel,
                onChanged: _onSliderChanged,
              ),
            ),
            const SizedBox(height: 2), // espace réduit
            // Labels sous chaque tick
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _priceLevels
                  .map((lvl) => Text(
                        lvl,
                        style: const TextStyle(
                          fontFamily: _fontFamilySans,
                          fontSize: 14,
                          color: _labelColor,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
