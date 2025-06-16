// lib/services/search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

/// Service de recherche de restaurants basé sur localisation, moments, lieux, cuisines et prix,
/// avec génération automatique des URLs de logo et photos.
class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Storage bucket et chemins
  static const String _bucketName = 'butter-vdef.firebasestorage.app';
  static const String _logosPath = 'Logos';
  static const String _photosPath = 'Photos restaurants';

  /// Recherche les restaurants selon les filtres :
  /// - [zones], [arrondissements], [communes] pour la géolocalisation.
  /// - [moments], [lieux], [cuisines], [prix] pour les critères.
  Future<List<Restaurant>> search({
    List<String>? zones,
    List<String>? arrondissements,
    List<String>? communes,
    List<String>? moments,
    List<String>? lieux,
    List<String>? cuisines,
    List<String>? prix,
    List<String>? restrictions,
    List<String>? ambiance,
  }) async {
    print('  zones:           ' + (zones?.toString() ?? 'null'));
    print('  arrondissements: ' + (arrondissements?.toString() ?? 'null'));
    print('  communes:        ' + (communes?.toString() ?? 'null'));
    print('  moments:         ' + (moments?.toString() ?? 'null'));
    print('  lieux:           ' + (lieux?.toString() ?? 'null'));
    print('  cuisines:        ' + (cuisines?.toString() ?? 'null'));
    print('  prix:            ' + (prix?.toString() ?? 'null'));
    print('  restrictions:    ' + (restrictions?.toString() ?? 'null'));
    print('  ambiance:        ' + (ambiance?.toString() ?? 'null'));

    // 1) Construction des groupes de codes postaux (OR géo)
    final geoGroups = _buildGeoGroups(zones, arrondissements, communes);

    // 2) Exécution des requêtes Firestore et enrichissement média
    final Map<String, Restaurant> resultsMap = {};
    
    // Requête de base pour la localisation
    for (var codes in geoGroups) {
      if (codes.isNotEmpty) {
        // Pour chaque code postal, on fait une requête séparée
        for (var code in codes) {
          var query = _firestore.collection('restaurants') as Query<Map<String, dynamic>>;
          query = query.where('arrondissement', isEqualTo: code);
          final snapshot = await query.get();
          for (var doc in snapshot.docs) {
            resultsMap[doc.id] = _mapDocToRestaurant(doc);
          }
        }
      } else {
        // Si pas de codes postaux, on récupère tous les restaurants
        var query = _firestore.collection('restaurants') as Query<Map<String, dynamic>>;
        final snapshot = await query.get();
        for (var doc in snapshot.docs) {
          resultsMap[doc.id] = _mapDocToRestaurant(doc);
        }
      }
    }

    // Filtrage en mémoire pour les autres critères
    final filteredResults = <String, Restaurant>{};
    for (var entry in resultsMap.entries) {
      final resto = entry.value;
      bool matches = true;

      // Moments
      if ((moments ?? []).isNotEmpty) {
        matches = matches && moments!.every((m) => resto.moments.contains(m));
      }

      // Lieux
      if ((lieux ?? []).isNotEmpty) {
        matches = matches && lieux!.every((l) => resto.lieux.contains(l));
      }

      // Cuisines
      if ((cuisines ?? []).isNotEmpty) {
        matches = matches && (cuisines!.contains(resto.specialiteTag) || 
            cuisines.any((c) => resto.cuisines.contains(c)));
      }

      // Prix
      if ((prix ?? []).isNotEmpty) {
        matches = matches && prix!.contains(resto.priceRange);
      }

      // Restrictions
      if ((restrictions ?? []).isNotEmpty) {
        matches = matches && restrictions!.any((r) => resto.restrictions.contains(r));
      }

      // Ambiance
      if ((ambiance ?? []).isNotEmpty) {
        matches = matches && ambiance!.every((a) => resto.ambiance.contains(a));
      }

      if (matches) {
        filteredResults[entry.key] = resto;
      }
    }

    // 3) Retourner la liste sans doublons
    final resultList = filteredResults.values.toList();
    print('[DEBUG][SearchService] Arrondissements des résultats:');
    for (var resto in resultList) {
      print('  - ${resto.name} : arrondissement=${resto.arrondissement}, adresse=${resto.fullAddress}');
    }
    // DEBUG : Affiche les restaurants ambigus (arrondissement != code postal dans l'adresse)
    for (var resto in resultList) {
      final codePostalInAddress = RegExp(r'75\d{3}').firstMatch(resto.fullAddress)?.group(0);
      if (codePostalInAddress != null &&
          codePostalInAddress != '750${resto.arrondissement.toString().padLeft(2, '0')}') {
        print('[AMBIGU] ${resto.name} : arrondissement=${resto.arrondissement}, adresse=${resto.fullAddress}');
      }
    }
    return resultList;
  }

  List<List<int>> _buildGeoGroups(
    List<String>? zones,
    List<String>? arrondissements,
    List<String>? communes,
  ) {
    final arrMap = Restaurant.arrondissementMap;
    final commMap = Restaurant.communeMap;

    const zoneArrLabels = {
      'Centre': ['1e','2e','3e','4e','5e','6e','7e','8e','9e'],
      'Ouest':  ['15e','16e','17e','18e'],
      'Est':    ['10e','11e','12e','13e','14e','19e','20e'],
    };
    const zoneCommunes = {
      'Ouest': ['Boulogne','Levallois','Neuilly','Saint-Cloud'],
      'Centre': [],
      'Est':    ['Charenton','Saint-Mandé','Saint-Ouen'],
    };
    const zoneExtra = {
      'Centre': ['75116'],
      'Ouest':  ['92270','92800'],
      'Est':    ['93110'],
    };

    final groups = <List<int>>[];

    void add(Set<String> codes) {
      final ints = codes.map(int.tryParse).whereType<int>().toList();
      if (ints.isNotEmpty) groups.add(ints);
    }

    // a) zones
    if (zones != null && zones.isNotEmpty) {
      for (var z in zones) {
        final codes = <String>{};
        for (var lbl in zoneArrLabels[z] ?? []) {
          final c = arrMap[lbl];
          if (c != null) codes.addAll(c);
        }
        for (var lbl in zoneCommunes[z] ?? []) {
          final c = commMap[lbl];
          if (c != null) codes.add(c);
        }
        codes.addAll(zoneExtra[z] ?? []);
        add(codes);
      }
    }

    // b) arrondissements
    if (arrondissements != null && arrondissements.isNotEmpty) {
      final codes = <String>{};
      for (var lbl in arrondissements) {
        final c = arrMap[lbl];
        if (c != null) codes.addAll(c);
      }
      print('[DEBUG][SearchService] Codes postaux utilisés pour arrondissements: $codes');
      add(codes);
    }

    // c) communes
    if (communes != null && communes.isNotEmpty) {
      final codes = communes
          .map((lbl) => commMap[lbl])
          .whereType<String>()
          .toSet();
      add(codes);
    }

    // si rien, un groupe vide pour ne pas bloquer filtres non-géo
    if (groups.isEmpty) groups.add([]);

    return groups;
  }

  Future<Query<Map<String, dynamic>>> _applyFilters(
    Query<Map<String, dynamic>> query, {
    required List<int> codes,
    List<String>? moments,
    List<String>? lieux,
    List<String>? specialites,
    List<String>? prix,
    List<String>? restrictions,
    List<String>? ambiance,
  }) async {
    // localisation
    if (codes.isNotEmpty) {
      query = codes.length == 1
          ? query.where('Arrondissement', isEqualTo: codes.first)
          : query.where('Arrondissement', whereIn: codes);
    }
    // moments
    for (var m in moments ?? []) {
      query = query.where('moments', arrayContains: m);
    }
    // lieux
    for (var l in lieux ?? []) {
      query = query.where('lieux', arrayContains: l);
    }
    // ambiance
    for (var a in ambiance ?? []) {
      if (a.contains('/')) continue; // Firestore interdit '/' dans les noms de champs
      query = query.where('ambiance.$a', isEqualTo: true);
    }
    // spécialité
    if ((specialites ?? []).isNotEmpty) {
      // On ne filtre pas par cuisine ici, on le fera après avoir récupéré les résultats
      // en vérifiant à la fois specialite_tag et cuisines
    }
    // prix
    if ((prix ?? []).isNotEmpty) {
      if (prix!.length == 1) {
        query = query.where('price_range', isEqualTo: prix[0]);
      } else {
        query = query.where('price_range', whereIn: prix);
      }
    }
    // restrictions
    if ((restrictions ?? []).isNotEmpty) {
      query = query.where('restrictions', arrayContainsAny: restrictions!);
    }
    return query;
  }

  // Ajout : Génération des URLs comme dans RestaurantService
  List<String> _generateImageUrls(String tag, {int min = 2, int max = 6}) =>
      List.generate(max - min + 1, (i) {
        final num = i + min;
        return _mediaUrl(_photosPath, '${tag}$num.png');
      });

  String _generateLogoUrl(String tag) => _mediaUrl(_logosPath, '${tag}1.png');

  String _mediaUrl(String folder, String filename) {
    final path = Uri.encodeComponent('$folder/$filename');
    // Pas de gestion de token ici, à adapter si besoin
    return 'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path?alt=media';
  }

  /// Transforme un DocumentSnapshot en Restaurant et génère logos + images.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    // on récupère tout le data brut
    final raw = doc.data() as Map<String, dynamic>? ?? {};
    final tag = (raw['tag'] ?? '').toString().toUpperCase();
    final logoUrl = tag.isNotEmpty ? _generateLogoUrl(tag) : null;
    final imageUrls = tag.isNotEmpty ? _generateImageUrls(tag) : <String>[];

    // on crée un Restaurant depuis le Map (il génère déjà logoUrl+imageUrls)
    // merci à Restaurant.fromMap qui contient la logique media
    // On injecte logoUrl et imageUrls dans le map si besoin
    final data = Map<String, dynamic>.from(raw);
    data['logoUrl'] = logoUrl;
    data['imageUrls'] = imageUrls;
    return Restaurant.fromMap(doc.id, data);
  }
}
