// lib/services/favorite_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing user favorites with real-time updates and local caching.
class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _prefsKey = 'favorite_ids';

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Checks if a restaurant is favorite (cache-first)
  Future<bool> isFavorite(String restaurantId) async {
    final ids = await getFavoriteRestaurantIds();
    return ids.contains(restaurantId);
  }

  /// Adds a restaurant to favorites (Firestore + cache)
  Future<void> addFavorite(String restaurantId) async {
    if (_uid == null) return;
    final userFavs = _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites');

    await userFavs.doc(restaurantId).set({'addedAt': FieldValue.serverTimestamp()});
    await _updateCacheFromFirestore();
  }

  /// Removes a restaurant from favorites (Firestore + cache)
  Future<void> removeFavorite(String restaurantId) async {
    if (_uid == null) return;
    final userFavs = _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites');

    await userFavs.doc(restaurantId).delete();
    await _updateCacheFromFirestore();
  }

  /// One-time fetch of favorite IDs, combining cache and network fallback
  Future<List<String>> getFavoriteRestaurantIds() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList(_prefsKey);
    if (cached != null && cached.isNotEmpty) {
      _updateCacheFromFirestore();
      return cached;
    }
    final fresh = await _fetchIdsFromFirestore();
    await prefs.setStringList(_prefsKey, fresh);
    return fresh;
  }

  /// Real-time stream of favorite IDs with local cache updates
  Stream<List<String>> watchFavoriteRestaurantIds() async* {
    if (_uid == null) {
      yield [];
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    yield prefs.getStringList(_prefsKey) ?? [];

    final stream = _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .snapshots();

    await for (final snapshot in stream) {
      final ids = snapshot.docs.map((d) => d.id).toList();
      await prefs.setStringList(_prefsKey, ids);
      yield ids;
    }
  }

  Future<List<String>> _fetchIdsFromFirestore() async {
    if (_uid == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .get();
    return snapshot.docs.map((d) => d.id).toList();
  }

  Future<void> _updateCacheFromFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _fetchIdsFromFirestore();
    await prefs.setStringList(_prefsKey, ids);
  }
}
