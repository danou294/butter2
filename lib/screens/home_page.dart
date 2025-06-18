// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../services/user_service.dart';
import '../widgets/restaurant_card.dart';
import 'search/search_page.dart';
import 'restaurant_detail_page.dart';

/// Page d'accueil avec pagination manuelle des restaurants.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _pageSize = 50;

  final RestaurantService _restaurantService = RestaurantService();
  final UserService _userService = UserService();

  List<Restaurant> _restaurants = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _prenom;

  @override
  void initState() {
    super.initState();
    _initUser();
    _clearCacheAndFetch();
  }

  Future<void> _initUser() async {
    final fetchedPrenom = await _userService.fetchCurrentUserPrenom();
    if (!mounted) return;
    final name = (fetchedPrenom?.trim().isNotEmpty == true)
        ? fetchedPrenom!
        : 'utilisateur';
    setState(() {
      _prenom = '${name[0].toUpperCase()}${name.substring(1)}';
    });
  }

  Future<void> _clearCacheAndFetch() async {
    await _restaurantService.clearCache();
    await _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final page = await _restaurantService.fetchPage(
        lastDocument: _lastDocument,
        pageSize: _pageSize,
      );
      
      setState(() {
        _restaurants.addAll(page.restaurants);
        _lastDocument = page.lastDocument;
        _isLoading = false;
        _hasMore = page.restaurants.length == _pageSize;
      });
      
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _restaurants = [];
      _lastDocument = null;
      _hasMore = true;
      _isLoading = false;
    });
    await _fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final headerHeight = height * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Accueil', 
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'InriaSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Vider le cache',
            onPressed: () async {
              await _restaurantService.clearCache();
              await _refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache vidé, liste rafraîchie !')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(headerHeight, width)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            _restaurants.isEmpty && !_isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Aucun restaurant trouvé',
                        style: TextStyle(
                          fontFamily: 'InriaSans',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < _restaurants.length) {
                            final resto = _restaurants[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: RestaurantCard(
                                restaurant: resto,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailPage(restaurantId: resto.id),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount: _restaurants.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.66,
                      ),
                    ),
                  ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox.shrink(),
                    ),
                  if (_hasMore && !_isLoading && _restaurants.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _fetchRestaurants,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            'Charger plus',
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 15, 
                              fontFamily: 'InriaSans',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_hasMore && _restaurants.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Tous les restaurants sont affichés.',
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        color: Colors.black.withOpacity(0.45),
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTop(width, height),
              _buildHeaderText(height, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTop(double width, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.3,
            child: Image.asset('assets/icon/app_icon2.png', fit: BoxFit.contain),
          ),
          SizedBox(
            width: width * 0.4,
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'InriaSans',
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Recherche personnalisée'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(double height, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white70,
              fontSize: height * 0.06,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _prenom ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: height * 0.12,
              fontWeight: FontWeight.bold,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width * 0.75,
            child: Text(
              "On t'a trouvé les meilleurs restos de Paris ;)",
              style: TextStyle(
                color: Colors.white70,
                fontSize: height * 0.06,
                fontFamily: 'InriaSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
