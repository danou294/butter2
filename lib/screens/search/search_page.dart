// lib/screens/search/search_page.dart

import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import 'package:butter/services/search_service.dart' as svc;
import 'search_header.dart';
import 'search_tabs.dart';
import 'filters/localization_filter.dart';
import 'filters/moment_filter.dart';
import 'filters/cuisine_filter.dart';
import 'filters/lieu_filter.dart';
import 'filters/ambiance_filter.dart';
import 'filters/prix_filter.dart';
import 'filters/restrictions_filter.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant_detail_page.dart';

const String _fontFamily = 'InriaSans';
const Color _filterBgUnselected = Color(0xFFF5F5F0);

// Liste des cuisines disponibles (doit correspondre à tes chips)
const List<String> _allCuisines = [
  'Africain',
  'Américain',
  'Chinois',
  'Coréen',
  'Français',
  'Grec',
  'Indien',
  'Israélien',
  'Italien',
  'Japonais',
  'Libanais',
  'Mexicain',
  'Oriental',
  'Péruvien',
  'Sud-Américain',
  'Thaï',
  'Vietnamien',
  'Other',
];

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  static const sections = [
    'Localisation',
    'Moment',
    'Cuisine',
    'Lieu',
    'Ambiance',
    'Prix',
    'Restrictions',
  ];

  late final TabController _tabController;
  final Set<String> _selectedFilters = {};
  List<Restaurant>? _results;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFilter(String key, bool selected) {
    setState(() {
      if (selected) _selectedFilters.add(key);
      else _selectedFilters.remove(key);
    });
  }

  Future<void> _executeSearch() async {
    final zones    = <String>[];
    final arrs     = <String>[];
    final comms    = <String>[];
    final moments  = <String>[];
    final cuisines = <String>[];
    final restrictions = <String>[];
    final ambiance = <String>[];

    for (var f in _selectedFilters) {
      if (Restaurant.directionGroups.containsKey(f)) {
        zones.add(f);
      } else if (Restaurant.arrondissementMap.containsKey(f)) {
        arrs.add(f);
      } else if (Restaurant.communeMap.containsKey(f)) {
        comms.add(f);
      } else if (_allCuisines.contains(f)) {
        cuisines.add(f);
      } else if (_isRestriction(f)) {
        restrictions.add(f);
      } else if (_isAmbiance(f)) {
        final value = AmbianceFilter.keyToValue[f] ?? f;
        ambiance.add(value);
      } else {
        moments.add(f);
      }
    }

    final results = await svc.SearchService().search(
      zones:           zones.isEmpty    ? null : zones,
      arrondissements: arrs.isEmpty     ? null : arrs,
      communes:        comms.isEmpty    ? null : comms,
      moments:         moments.isEmpty  ? null : moments,
      cuisines:        cuisines.isEmpty ? null : cuisines,
      restrictions:    restrictions.isEmpty ? null : restrictions,
      ambiance:        ambiance.isEmpty ? null : ambiance,
    );

    setState(() {
      _results = results;
    });
  }

  Widget _buildHeader(double height, double width) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background-liste.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.only(bottom: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton : revenir aux filtres
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: SizedBox(
                    width: width * 0.55,
                    height: height * 0.12,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _results = null),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: height * 0.035,
                          fontFamily: _fontFamily,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Modifier mes filtres'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Titre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Résultats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Compteur
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '${_results!.length} ' +
                      (_results!.length > 1 ? 'adresses trouvées' : 'adresse trouvée'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: height * 0.06,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final list = _results!;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final headerH = screenH * 0.3;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Aucun résultat trouvé',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(headerH, screenW)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final resto = list[i];
                return GestureDetector(
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(restaurant: resto),
                    ),
                  ),
                  child: RestaurantCard(restaurant: resto),
                );
              },
              childCount: list.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterView() {
    Widget tabContent(String section) {
      switch (section) {
        case 'Localisation':
          return LocalizationFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Moment':
          return MomentFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Cuisine':
          return CuisineFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Lieu':
          return LieuFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Ambiance':
          return AmbianceFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Prix':
          return PrixFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        case 'Restrictions':
          return RestrictionsFilter(
            selected: _selectedFilters,
            onToggle: _toggleFilter,
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return Column(
      children: [
        const SearchHeader(),
        SearchTabs(controller: _tabController, sections: sections),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: sections.map(tabContent).toList(),
          ),
        ),
        if (_selectedFilters.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, idx) {
                final label = _selectedFilters.elementAt(idx);
                return Chip(
                  label: Text(label,
                      style: const TextStyle(fontFamily: _fontFamily)),
                  backgroundColor: _filterBgUnselected,
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _toggleFilter(label, false),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _selectedFilters.clear()),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _filterBgUnselected,
                    side: const BorderSide(color: Colors.black12),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _executeSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    'Voir les résultats',
                    style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: (_results == null) ? _buildFilterView() : _buildResultsView(),
      // la bottomNavigationBar reste dans MainNavigation
    );
  }

  bool _isRestriction(String f) {
    const restrictionsList = [
      'Casher (certifié)',
      'Casher friendly (tout est casher mais pas de teouda)',
      'Viande casher',
      'Végétarien',
      'Vegan',
    ];
    return restrictionsList.contains(f);
  }

  bool _isAmbiance(String f) {
    const ambianceList = [
      'classique',
      'date',
      'festif',
      'intimiste',
    ];
    return ambianceList.contains(f.toLowerCase());
  }
}
