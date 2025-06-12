// lib/screens/restaurant_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../services/restaurant_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';

class RestaurantDetailPage extends StatelessWidget {
  final String restaurantId;

  const RestaurantDetailPage({Key? key, required this.restaurantId}) : super(key: key);

  Future<Restaurant?> fetchRestaurant() async {
    return await RestaurantService().fetchById(restaurantId);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildChip(String text, {Color? bgColor, Color? textColor}) {
    return Chip(
      label: Text(text,
          style: AppTextStyles.tag.copyWith(color: textColor ?? AppColors.darkGrey)),
      backgroundColor: bgColor ?? AppColors.lightGrey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant?>(
      future: fetchRestaurant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Restaurant introuvable')),
          );
        }
        final restaurant = snapshot.data!;
        print('--- DÉTAILS DU RESTAURANT ---');
        print('id: \'${restaurant.id}\'');
        print('name: \'${restaurant.name}\'');
        print('rawName: \'${restaurant.rawName}\'');
        print('fullAddress: \'${restaurant.fullAddress}\'');
        print('arrondissement: ${restaurant.arrondissement}');
        print('commentaire: \'${restaurant.commentaire}\'');
        print('hours: \'${restaurant.hours}\'');
        print('phone: \'${restaurant.phone}\'');
        print('website: \'${restaurant.website}\'');
        print('reservationLink: \'${restaurant.reservationLink}\'');
        print('instagram: \'${restaurant.instagram}\'');
        print('googleLink: \'${restaurant.googleLink}\'');
        print('menuLink: \'${restaurant.menuLink}\'');
        print('types: ${restaurant.types}');
        print('moments: ${restaurant.moments}');
        print('lieux: ${restaurant.lieux}');
        print('ambiance: ${restaurant.ambiance}');
        print('priceRange: \'${restaurant.priceRange}\'');
        print('cuisines: ${restaurant.cuisines}');
        print('restrictions: ${restaurant.restrictions}');
        print('hasTerrace: ${restaurant.hasTerrace}');
        print('terraceLocs: ${restaurant.terraceLocs}');
        print('stationsMetro: ${restaurant.stationsMetro}');
        print('moreInfo: \'${restaurant.moreInfo}\'' );
        print('logoUrl: \'${restaurant.logoUrl}\'' );
        print('imageUrls: ${restaurant.imageUrls}');
        print('specialiteTag: \'${restaurant.specialiteTag}\'' );
        print('tag: \'${restaurant.tag}\'' );
        print('-----------------------------');
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Image slider with caching
                if (restaurant.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 240,
                    child: PageView(
                      children: restaurant.imageUrls.map((url) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(AppTheme.borderRadius)),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            cacheKey: url,
                            placeholder: (_, __) => Container(color: AppColors.lightGrey),
                            errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircleAvatar(
                      backgroundColor: AppColors.darkOverlay,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 20,
                      ),

                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + actions
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: AppTextStyles.title,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_outlined, color: AppColors.darkGrey),
                              onPressed: () {
                                final text = """
J'ai découvert ce resto sur Butter :

${restaurant.name}, ${restaurant.fullAddress}

Télécharge Butter pour avoir accès à toutes les meilleures adresses de Paris : https://butter.paris/app
""";
                                Share.share(text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_border,
                                  color: AppColors.darkGrey),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        // Subtitle
                        if (restaurant.cuisines.isNotEmpty)
                          Text(
                            restaurant.cuisines.join(', '),
                            style: AppTextStyles.subtitle,
                          ),
                        const SizedBox(height: 16),



                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  debugPrint('Reservation URL: ${restaurant.reservationLink}');
                                  if (restaurant.reservationLink.isNotEmpty) {
                                    _launchUrl(restaurant.reservationLink);
                                  }
                                },
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(
                                      BorderSide(color: AppColors.primary)),
                                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (states) => AppColors.primary,
                                  ),
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (states) => states.contains(MaterialState.hovered)
                                        ? AppColors.primary.withOpacity(0.1)
                                        : null,
                                  ),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(vertical: 14)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadius),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Faire une réservation',
                                  style: AppTextStyles.button.copyWith(
                                      color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  debugPrint('Menu URL: ${restaurant.menuLink}');
                                  if (restaurant.menuLink.isNotEmpty) {
                                    _launchUrl(restaurant.menuLink);
                                  }
                                },
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(
                                      BorderSide(color: AppColors.darkGrey)),
                                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                    (states) => AppColors.darkGrey,
                                  ),
                                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                    (states) => states.contains(MaterialState.hovered)
                                        ? AppColors.lightGrey
                                        : null,
                                  ),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 14)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadius),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Menu',
                                  style: AppTextStyles.button.copyWith(
                                      color: AppColors.darkGrey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Status, price, address
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip('Ouvert',
                                bgColor: AppColors.openLight,
                                textColor: AppColors.openDark),
                            _buildChip(restaurant.priceRange),
                            _buildChip(restaurant.fullAddress,
                                bgColor: AppColors.white,
                                textColor: AppColors.darkGrey),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sections
                        if (restaurant.types.isNotEmpty) ...[
                          Text('Type', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 4),
                          Wrap(
                              spacing: 6,
                              children: restaurant.types.map((t) => _buildChip(t)).toList()),
                          const SizedBox(height: 12),
                        ],

                        if (restaurant.commentaire.isNotEmpty) ...[
                          Text('À propos', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 4),
                          Text(restaurant.commentaire, style: AppTextStyles.body),
                          const SizedBox(height: 12),
                        ],

                        if (restaurant.hours.isNotEmpty) ...[
                          Text('Horaires', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 4),
                          Text(restaurant.hours, style: AppTextStyles.body),
                          const SizedBox(height: 12),
                        ],

                        if (restaurant.stationsMetro.isNotEmpty) ...[
                          Text('Métro', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 4),
                          Wrap(
                              spacing: 6,
                              children:
                                  restaurant.stationsMetro.map((s) => _buildChip(s)).toList()),
                          const SizedBox(height: 12),
                        ],

                        // Contact Icons
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (restaurant.phone.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.phone,
                                    color: AppColors.darkGrey),
                                onPressed: () => _launchUrl('tel:${restaurant.phone}'),
                              ),
                            if (restaurant.website.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.language,
                                    color: AppColors.darkGrey),
                                onPressed: () => _launchUrl(restaurant.website),
                              ),
                            if (restaurant.instagram.isNotEmpty)
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.instagram, color: AppColors.darkGrey),
                                onPressed: () => _launchUrl(restaurant.instagram),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Note: add to pubspec.yaml:
// dependencies:
//   cached_network_image: ^3.2.3
//   url_launcher: ^6.1.7
