// lib/screens/search/filters/localization_filter.dart

import 'package:flutter/material.dart';
import '../../../models/restaurant.dart';

// TODO: Adapte ces constantes à ta charte graphique
const Color _selectedBg = Color(0xFFBFB9A4);
const Color _unselectedBg = Color(0xFFF5F5F0);
const Color _labelColor = Colors.black;
const String _fontFamily = 'InriaSans';

typedef OnToggle = void Function(String label, bool isSelected);

/// Représente un item de filtre générique avec dimensions et icône optionnelle
class _FilterItem {
  final String label;
  final double width;
  final double height;
  final double fontSize;
  final String? iconPath;

  const _FilterItem({
    required this.label,
    required this.width,
    required this.height,
    required this.fontSize,
    this.iconPath,
  });
}

class LocalizationFilter extends StatelessWidget {
  final Set<String> selected;
  final OnToggle onToggle;

  const LocalizationFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  Widget _buildTile(_FilterItem item) {
    final isSelected = selected.contains(item.label);
    return GestureDetector(
      onTap: () => onToggle(item.label, !isSelected),
      child: Container(
        width: item.width,
        height: item.height,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : _unselectedBg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: item.iconPath != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    item.iconPath!,
                    width: item.width * 0.5,
                    height: item.height * 0.5,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: item.fontSize,
                      color: _labelColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              )
            : Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: item.fontSize,
                  color: _labelColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 1) Directions définies dans le modèle Restaurant
    final directions = Restaurant.directionGroups.keys.map((dir) {
      return _FilterItem(
        label: dir,
        width: screenWidth / 4,
        height: screenWidth / 4,
        fontSize: 12,
        iconPath: 'assets/direction/${dir.toLowerCase()}.png',
      );
    }).toList();

    // 2) Arrondissements à partir du modèle
    final arrondissements = Restaurant.arrondissementMap.keys.map((a) {
      return _FilterItem(
        label: a,
        width: 38,
        height: 38,
        fontSize: 12,
      );
    }).toList();

    // 3) Communes à partir du modèle
    final communes = Restaurant.communeMap.keys.map((c) {
      return _FilterItem(
        label: c,
        width: 78,
        height: 36,
        fontSize: 12,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Directions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: directions.map(_buildTile).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Arrondissements
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: arrondissements.map(_buildTile).toList(),
          ),
          const SizedBox(height: 24),

          // Communes
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: communes.map(_buildTile).toList(),
          ),
        ],
      ),
    );
  }
}
