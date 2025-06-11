import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/favorite_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    this.onTap,
  }) : super(key: key);

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  final _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.restaurant.id);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.restaurant.id);
    } else {
      await _favoriteService.addFavorite(widget.restaurant.id);
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Ligne "ARR | CUISINE | PRIX"
  Widget _buildTopInfo() {
    final r = widget.restaurant;
    final arr = r.arrondissement > 0 ? r.arrondissement.toString() : '';
    final cuisine = r.cuisines.isNotEmpty ? _capitalize(r.cuisines.first) : '';
    final price = r.priceRange.isNotEmpty ? r.priceRange : '';
    final parts = [arr, cuisine, price].where((p) => p.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 32),
      child: Text(
        parts.join(' | '),
        style: const TextStyle(
          fontFamily: 'InriaSans',
          fontSize: 10,
          color: Color(0xFF535353),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Affiche le logo (ou placeholder si absent)
  Widget _buildLogo() {
    final logoUrl = widget.restaurant.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          height: 40,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          ),
          errorWidget: (context, url, error) => _placeholderLogo(),
        ),
      );
    }
    return _placeholderLogo();
  }

  /// Petit cercle avec initiale en fallback
  Widget _placeholderLogo() {
    final initial = widget.restaurant.name.isNotEmpty
        ? widget.restaurant.name[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhotoRow() {
    final images = widget.restaurant.imageUrls;
    final img2 = images.length > 0 ? images[0] : null;
    final img3 = images.length > 1 ? images[1] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Row(
        children: List.generate(2, (i) {
          final imgUrl = i == 0 ? img2 : img3;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i == 1 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.grey.shade300,
              ),
              clipBehavior: Clip.antiAlias,
              child: imgUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW * 0.45;
    final cardH = cardW * 1.5;

    return SizedBox(
      width: cardW,
      height: cardH,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopInfo(),
                  const SizedBox(height: 2),
                  _buildLogo(),
                  const SizedBox(height: 6),
                  Expanded(child: _buildPhotoRow()),
                ],
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Image.asset(
                    _isFavorite
                        ? 'assets/navigation-tools/favoris_black.png'
                        : 'assets/navigation-tools/favoris.png',
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
