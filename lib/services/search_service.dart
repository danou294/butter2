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
    print('[DEBUG] ambiance envoyé au service : ${ambiance?.toString() ?? 'null'}');
    print('[DEBUG] Filtres transmis au service :');
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
    for (var codes in geoGroups) {
      // PATCH restrictions : deux requêtes si restrictions non vide
      if ((restrictions ?? []).isNotEmpty) {
        final baseQuery = _firestore.collection('restaurants') as Query<Map<String, dynamic>>;
        // 1. arrayContainsAny (cas array)
        final queryArray = _applyFilters(
          baseQuery,
          codes: codes,
          moments: moments,
          lieux: lieux,
          specialites: cuisines,
          prix: prix,
          restrictions: null,
          ambiance: ambiance,
        );
        final snapArray = await queryArray.where('restrictions', arrayContainsAny: restrictions!).get();
        for (var doc in snapArray.docs) {
          resultsMap[doc.id] = _mapDocToRestaurant(doc);
        }
        // 2. isEqualTo (cas string)
        for (var r in restrictions!) {
          final queryStr = _applyFilters(
            baseQuery,
            codes: codes,
            moments: moments,
            lieux: lieux,
            specialites: cuisines,
            prix: prix,
            restrictions: null,
            ambiance: ambiance,
          );
          final snapStr = await queryStr.where('restrictions', isEqualTo: r).get();
          for (var doc in snapStr.docs) {
            resultsMap[doc.id] = _mapDocToRestaurant(doc);
          }
        }
        continue;
      }

      // PATCH ambiance : requêtes multiples si ambiance non vide
      if ((ambiance ?? []).isNotEmpty) {
        final baseQuery = _firestore.collection('restaurants') as Query<Map<String, dynamic>>;
        // 1. arrayContainsAny (cas array)
        final queryArray = _applyFilters(
          baseQuery,
          codes: codes,
          moments: moments,
          lieux: lieux,
          specialites: cuisines,
          prix: prix,
          restrictions: restrictions,
          ambiance: null,
        );
        final snapArray = await queryArray.where('ambiance', arrayContainsAny: ambiance!).get();
        for (var doc in snapArray.docs) {
          resultsMap[doc.id] = _mapDocToRestaurant(doc);
        }
        // 2. isEqualTo (cas string)
        for (var a in ambiance!) {
          if (a.contains('/')) continue; // Firestore interdit '/' dans les noms de champs
          final queryStr = _applyFilters(
            baseQuery,
            codes: codes,
            moments: moments,
            lieux: lieux,
            specialites: cuisines,
            prix: prix,
            restrictions: restrictions,
            ambiance: null,
          );
          final snapStr = await queryStr.where('ambiance.$a', isEqualTo: true).get();
          for (var doc in snapStr.docs) {
            resultsMap[doc.id] = _mapDocToRestaurant(doc);
          }
        }
        // 3. map de booléens : une requête par valeur
        for (var a in ambiance!) {
          if (a.contains('/')) continue; // Firestore interdit '/' dans les noms de champs
          final queryBool = _applyFilters(
            baseQuery,
            codes: codes,
            moments: moments,
            lieux: lieux,
            specialites: cuisines,
            prix: prix,
            restrictions: restrictions,
            ambiance: null,
          );
          final snapBool = await queryBool.where('ambiance.$a', isEqualTo: true).get();
          for (var doc in snapBool.docs) {
            resultsMap[doc.id] = _mapDocToRestaurant(doc);
          }
        }
        continue;
      }

      // --- PATCH ARRONDISSEMENT ---
      // 1. Requête sur 'Arrondissement' (majuscule)
      var queryMaj = _applyFilters(
        _firestore.collection('restaurants') as Query<Map<String, dynamic>>,
        codes: [], // on ne filtre pas ici, on le fait juste après
        moments: moments,
        lieux: lieux,
        specialites: cuisines,
        prix: prix,
        restrictions: restrictions,
        ambiance: ambiance,
      );
      if (codes.isNotEmpty) {
        queryMaj = codes.length == 1
            ? queryMaj.where('Arrondissement', isEqualTo: codes.first)
            : queryMaj.where('Arrondissement', whereIn: codes);
      }
      final snapMaj = await queryMaj.get();
      for (var doc in snapMaj.docs) {
        resultsMap[doc.id] = _mapDocToRestaurant(doc);
      }

      // 2. Requête sur 'arrondissement' (minuscule)
      var queryMin = _applyFilters(
        _firestore.collection('restaurants') as Query<Map<String, dynamic>>,
        codes: [], // on ne filtre pas ici, on le fait juste après
        moments: moments,
        lieux: lieux,
        specialites: cuisines,
        prix: prix,
        restrictions: restrictions,
        ambiance: ambiance,
      );
      if (codes.isNotEmpty) {
        queryMin = codes.length == 1
            ? queryMin.where('arrondissement', isEqualTo: codes.first)
            : queryMin.where('arrondissement', whereIn: codes);
      }
      final snapMin = await queryMin.get();
      for (var doc in snapMin.docs) {
        resultsMap[doc.id] = _mapDocToRestaurant(doc);
      }
    }

    // 3) Retourner la liste sans doublons
    return resultsMap.values.toList();
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
          if (c != null) codes.add(c);
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
        if (c != null) codes.add(c);
        if (lbl == '16e') codes.add('75116');
      }
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

  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> query, {
    required List<int> codes,
    List<String>? moments,
    List<String>? lieux,
    List<String>? specialites,
    List<String>? prix,
    List<String>? restrictions,
    List<String>? ambiance,
  }) {
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
      if (specialites!.length == 1) {
        query = query.where('specialite_tag', isEqualTo: specialites.first);
      } else {
        query = query.where('specialite_tag', whereIn: specialites);
      }
    }
    // prix
    if ((prix ?? []).isNotEmpty) {
      query = query.where('price_range', arrayContainsAny: prix!);
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
