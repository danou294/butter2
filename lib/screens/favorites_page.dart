// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/restaurant.dart';
import '../services/favorite_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/restaurant_card.dart';
import 'main_navigation.dart';
import 'restaurant_detail_page.dart';

/// Page affichant les restaurants favoris de l'utilisateur,
/// en se basant sur le cache local et une mise à jour réseau via fetchPage.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const int _fetchSize = 10000; // assez grand pour récupérer tous les favoris

  final FavoriteService _favoriteService = FavoriteService();
  final RestaurantService _restaurantService = RestaurantService();

  List<Restaurant> _favorites = [];
  bool _loading = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _checkAndLoadFavorites();
  }

  Future<void> _checkAndLoadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() {
        _loading = false;
        _favorites = [];
      });
      return;
    }
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Récupère les IDs favoris
    final ids = await _favoriteService.getFavoriteRestaurantIds();

    // 1) Chargement dans le cache local
    final cached = await _restaurantService.fetchFromCache();
    final fromCache = cached.where((r) => ids.contains(r.id)).toList();
    if (mounted) {
      setState(() {
        _favorites = fromCache;
        _loading = false;
      });
    }

    // 2) Chargement réseau paginé (une seule page)
    try {
      final page = await _restaurantService.fetchPage(
        lastDocument: null,
        pageSize: _fetchSize,
      );
      final networkList = page.restaurants.where((r) => ids.contains(r.id)).toList();
      if (mounted) {
        setState(() {
          _favorites = networkList;
        });
      }
    } catch (_) {
      // On ignore l'erreur et conserve le cache
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.3;

    final user = FirebaseAuth.instance.currentUser;
    final isAnon = user == null || user.isAnonymous;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(headerHeight, screenWidth, isAnon)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (isAnon)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Connecte-toi pour enregistrer des favoris !',
                  style: TextStyle(fontSize: 18, color: Colors.black54, fontFamily: 'InriaSans'),
                ),
              ),
            )
          else if (_favorites.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Aucun favori enregistré',
                  style: TextStyle(fontSize: 18, color: Colors.black54, fontFamily: 'InriaSans'),
                ),
              ),
            )
          else
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
                    final resto = _favorites[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailPage(restaurant: resto),
                        ),
                      ),
                      child: RestaurantCard(restaurant: resto),
                    );
                  },
                  childCount: _favorites.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double height, double width, bool isAnon) {
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
              _buildHeaderButton(width, height),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Mes favoris',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  isAnon
                      ? 'Connecte-toi pour enregistrer des adresses !'
                      : '${_favorites.length} ' + (_favorites.length > 1 ? 'adresses enregistrées' : 'adresse enregistrée'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: height * 0.06,
                    fontFamily: 'InriaSans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(double width, double height) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: SizedBox(
          width: width * 0.55,
          height: height * 0.12,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigation()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: height * 0.035,
                fontFamily: 'InriaSans',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Découvrir des nouvelles adresses'),
            ),
          ),
        ),
      ),
    );
  }
}