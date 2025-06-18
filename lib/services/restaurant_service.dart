// lib/services/restaurant_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/restaurant.dart';

/// Conteneur pour résultats paginés depuis Firestore.
class PaginatedRestaurants {
  final List<Restaurant> restaurants;
  final DocumentSnapshot? lastDocument;

  PaginatedRestaurants({
    required this.restaurants,
    this.lastDocument,
  });
}

/// Service pour gérer cache local et pagination Firestore des restaurants,
/// avec génération des URLs de logo et photos.
class RestaurantService {
  final FirebaseFirestore _firestore;

  static const String _cacheKey = 'restaurants_cache';
  static const String _bucketName = 'butter-vdef.firebasestorage.app';
  static const String _logosPath = 'Logos';
  static const String _photosPath = 'Photos restaurants';

  RestaurantService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Charge tous les restaurants depuis le cache local.
  Future<List<Restaurant>> fetchFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadFromCache(prefs);
  }

  /// Récupère une page de restaurants depuis Firestore, met à jour le cache complet.
  Future<PaginatedRestaurants> fetchPage({
    DocumentSnapshot? lastDocument,
    required int pageSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _loadFromCache(prefs);
    
    // Vider le cache si il contient des données dans l'ancien format
    if (existing.isNotEmpty) {
      try {
        // Tester si le premier restaurant a l'ancien format
        final firstRestaurant = existing.first;
        if (firstRestaurant.fullAddress.isEmpty && firstRestaurant.arrondissement == 0) {
          await clearCache();
        }
      } catch (e) {
        await clearCache();
      }
    }
    
    try {
      var query = _firestore.collection('restaurants').limit(pageSize);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      final snapshot = await query.get();
      final newList = snapshot.docs.map(_mapDocToRestaurant).toList();
      // Concatène et déduplique
      final map = <String, Restaurant>{};
      for (var r in [...existing, ...newList]) {
        map[r.id] = r;
      }
      final combined = map.values.toList();
      await _saveToCache(prefs, combined);
      return PaginatedRestaurants(
        restaurants: newList,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e, stack) {
      // Fallback cache complet
      return PaginatedRestaurants(restaurants: existing, lastDocument: null);
    }
  }

  /// Vide le cache local.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  /// Génère les URLs des photos (<TAG>2.png à <TAG>6.png).
  List<String> _generateImageUrls(String tag, {int min = 2, int max = 6}) =>
      List.generate(max - min + 1, (i) {
        final num = i + min;
        return _mediaUrl(_photosPath, '${tag}$num.png');
      });

  /// Génère l'URL du logo (<TAG>1.png).
  String _generateLogoUrl(String tag) => _mediaUrl(_logosPath, '${tag}1.png');

  /// Génère une URL de média depuis Firebase Storage.
  String _mediaUrl(String folder, String filename) {
    final path = Uri.encodeComponent('$folder/$filename');
    return 'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path?alt=media';
  }

  /// Transforme un DocumentSnapshot en Restaurant normalisé et ajoute URLs.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map);
    
    final tag = (raw['tag'] ?? '').toString().toUpperCase();
    final logoUrl = tag.isNotEmpty ? _generateLogoUrl(tag) : null;
    final imageUrls = tag.isNotEmpty ? _generateImageUrls(tag) : <String>[];

    // Utiliser directement les données Firestore sans transformation
    final data = <String, dynamic>{
      'name': raw['name'] ?? '',
      'raw_name': raw['raw_name'] ?? '',
      'address': raw['address'] ?? '',
      'arrondissement': raw['arrondissement'] ?? 0,
      'hours': raw['hours'] ?? '',
      'hours_structured': raw['hours_structured'] ?? {},
      'more_info': raw['more_info'] ?? '',
      'phone': raw['phone'] ?? '',
      'website': raw['website'] ?? '',
      'reservation_link': raw['reservation_link'] ?? '',
      'instagram_link': raw['instagram_link'] ?? '',
      'google_link': raw['google_link'] ?? '',
      'lien_menu': raw['lien_menu'] ?? '',
      'types': raw['types'] ?? [],
      'moments': raw['moments'] ?? [],
      'lieux': raw['lieux'] ?? [],
      'ambiance': raw['ambiance'] ?? [],
      'price_range': raw['price_range'] ?? '',
      'cuisines': raw['cuisines'] ?? [],
      'restrictions': raw['restrictions'] ?? [],
      'has_terrace': raw['has_terrace'] ?? false,
      'terrace_locs': raw['terrace_locs'] ?? [],
      'stations_metro': raw['stations_metro'] ?? [],
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'specialite_tag': raw['specialite_tag'] ?? '',
      'tag': raw['tag'] ?? '',
    };

    return Restaurant.fromMap(doc.id, data);
  }

  /// Sauvegarde la liste en cache local.
  Future<void> _saveToCache(SharedPreferences prefs, List<Restaurant> list) async {
    final jsonList = list.map((r) {
      final map = r.toJson()..['id'] = r.id;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_cacheKey, jsonList);
  }

  /// Charge depuis cache local.
  List<Restaurant> _loadFromCache(SharedPreferences prefs) {
    final data = prefs.getStringList(_cacheKey);
    if (data == null || data.isEmpty) return <Restaurant>[];
    return data.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      final id = map.remove('id') as String;
      return Restaurant.fromMap(id, map);
    }).toList();
  }

  /// Récupère un restaurant par son identifiant Firestore.
  Future<Restaurant?> fetchById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (!doc.exists) return null;
      return _mapDocToRestaurant(doc);
    } catch (e) {
      return null;
    }
  }
}
