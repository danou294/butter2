// lib/screens/restaurant_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../services/restaurant_service.dart';
import '../services/favorite_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

// Widget pour gérer les horaires dynamiques
class DynamicHoursWidget extends StatefulWidget {
  final Map<String, dynamic> hoursStructured;

  const DynamicHoursWidget({
    Key? key,
    required this.hoursStructured,
  }) : super(key: key);

  @override
  State<DynamicHoursWidget> createState() => _DynamicHoursWidgetState();
}

class _DynamicHoursWidgetState extends State<DynamicHoursWidget> {
  bool _isExpanded = false;

  // Mapping des jours de la semaine
  static const Map<int, String> _daysOfWeek = {
    1: 'Lundi',
    2: 'Mardi', 
    3: 'Mercredi',
    4: 'Jeudi',
    5: 'Vendredi',
    6: 'Samedi',
    7: 'Dimanche',
  };

  // Vérifie si le restaurant est ouvert maintenant
  bool _isOpenNow() {
    final now = DateTime.now();
    final currentDay = _daysOfWeek[now.weekday];
    if (currentDay == null) return false;
    
    final todayHours = widget.hoursStructured[currentDay];
    
    if (todayHours == null || todayHours['closed'] == true) {
      return false;
    }

    final currentTime = now.hour * 60 + now.minute; // Minutes depuis minuit
    
    // Vérifier service_1 (déjeuner)
    if (todayHours['service_1'] != null) {
      final service1Range = _parseTimeRange(todayHours['service_1']);
      if (service1Range != null && 
          service1Range['start'] != null &&
          service1Range['end'] != null &&
          currentTime >= service1Range['start']! && 
          currentTime <= service1Range['end']!) {
        return true;
      }
    }
    
    // Vérifier service_2 (dîner)
    if (todayHours['service_2'] != null) {
      final service2Range = _parseTimeRange(todayHours['service_2']);
      if (service2Range != null && 
          service2Range['start'] != null &&
          service2Range['end'] != null &&
          currentTime >= service2Range['start']! && 
          currentTime <= service2Range['end']!) {
        return true;
      }
    }
    
    return false;
  }

  // Parse une plage horaire (ex: "18:30 - 00:00")
  Map<String, int>? _parseTimeRange(String timeRange) {
    try {
      final parts = timeRange.split(' - ');
      if (parts.length != 2) return null;
      
      final startTime = _parseTime(parts[0].trim());
      final endTime = _parseTime(parts[1].trim());
      
      if (startTime != null && endTime != null) {
        // Si l'heure de fin est 00:00, on la convertit en 24:00 (1440 minutes)
        final adjustedEndTime = endTime == 0 ? 1440 : endTime;
        
        return {
          'start': startTime,
          'end': adjustedEndTime,
        };
      }
    } catch (e) {
      debugPrint('Erreur parsing horaires: $e');
    }
    return null;
  }

  // Parse une heure (ex: "12:30")
  int? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;
      
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      
      return hours * 60 + minutes;
    } catch (e) {
      return null;
    }
  }

  // Obtient les horaires du jour actuel
  Map<String, dynamic>? _getCurrentDayHours() {
    final now = DateTime.now();
    final currentDay = _daysOfWeek[now.weekday];
    if (currentDay == null) return null;
    return widget.hoursStructured[currentDay];
  }

  // Formate les horaires pour l'affichage
  String _formatHours(Map<String, dynamic> dayHours) {
    if (dayHours['closed'] == true) {
      return 'Fermé';
    }
    
    final services = <String>[];
    if (dayHours['service_1'] != null) {
      services.add(dayHours['service_1']);
    }
    if (dayHours['service_2'] != null) {
      services.add(dayHours['service_2']);
    }
    
    return services.join(' et ');
  }

  @override
  Widget build(BuildContext context) {
    final currentDay = _daysOfWeek[DateTime.now().weekday] ?? 'Inconnu';
    final currentDayHours = _getCurrentDayHours();
    final isOpen = _isOpenNow();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Row(
          children: [
            Icon(
              Icons.access_time,
              color: AppColors.darkGrey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentDay,
                    style: const TextStyle(
                      fontFamily: 'InriaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (currentDayHours != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatHours(currentDayHours),
                      style: const TextStyle(
                        fontFamily: 'InriaSans',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isOpen ? 'Ouvert' : 'Fermé',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InriaSans',
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _daysOfWeek.values.map((day) {
                final dayHours = widget.hoursStructured[day];
                final isCurrentDay = day == currentDay;
                
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          day,
                          style: TextStyle(
                            fontFamily: 'InriaSans',
                            fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentDay ? AppColors.primary : AppColors.darkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          dayHours != null ? _formatHours(dayHours) : 'Non renseigné',
                          style: const TextStyle(
                            fontFamily: 'InriaSans',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoriteService.isFavorite(widget.restaurantId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Opération en arrière-plan
    if (_isFavorite) {
      _favoriteService.addFavorite(widget.restaurantId);
    } else {
      _favoriteService.removeFavorite(widget.restaurantId);
    }
  }

  Future<Restaurant?> fetchRestaurant() async {
    return await RestaurantService().fetchById(widget.restaurantId);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'InriaSans',
          fontSize: 10,
          color: textColor ?? AppColors.darkGrey,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Nouvelle fonction pour construire les chips des tags du restaurant
  Widget _buildTagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'InriaSans',
          fontSize: 10,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Widget pour afficher les stations de métro avec leurs lignes
  Widget _buildMetroStations(Restaurant restaurant) {
    if (restaurant.stationsMetroStructured.isNotEmpty) {
      // Nouveau format : afficher chaque station avec ses icônes SVG
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: restaurant.stationsMetroStructured.map((stationData) {
          final stationName = stationData['station'] as String? ?? '';
          final rawLines = stationData['lines'] ?? [];
          
          // Traitement des lignes : parsing robuste
          List<String> lines;
          if (rawLines is List) {
            lines = rawLines.map((e) => e.toString().trim()).toList();
          } else if (rawLines is String) {
            lines = rawLines.split(',').map((e) => e.trim()).toList();
          } else {
            lines = [];
          }
          
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom de la station avec icône de localisation
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        stationName,
                        style: const TextStyle(
                          fontFamily: 'InriaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (lines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Icônes des lignes de métro
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: lines.map((line) => _buildMetroLineIcon(line)).toList(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      );
    } else {
      // Ancien format : afficher juste les noms des stations
      return Wrap(
        spacing: 6,
        children: restaurant.stationNames.map((s) => _buildChip(s)).toList(),
      );
    }
  }

  // Widget pour afficher une icône de ligne de métro
  Widget _buildMetroLineIcon(String line) {
    final iconPath = _getMetroIconPath(line);
    
    if (iconPath != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 28,
          height: 28,
        ),
      );
    } else {
      // Fallback si l'icône n'existe pas
      return Container(
        width: 28,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  // Fonction pour obtenir le chemin de l'icône SVG d'une ligne de métro
  String? _getMetroIconPath(String line) {
    // Normaliser le nom de la ligne pour correspondre aux fichiers SVG
    final normalizedLine = line.toLowerCase().replaceAll(' ', '');
    
    switch (normalizedLine) {
      case '1': return 'assets/metro_icons/metro_1.svg';
      case '2': return 'assets/metro_icons/metro_2.svg';
      case '3': return 'assets/metro_icons/metro_3.svg';
      case '3b':
      case '3bis': return 'assets/metro_icons/metro_3bis.svg';
      case '4': return 'assets/metro_icons/metro_4.svg';
      case '5': return 'assets/metro_icons/metro_5.svg';
      case '6': return 'assets/metro_icons/metro_6.svg';
      case '7': return 'assets/metro_icons/metro_7.svg';
      case '7b':
      case '7bis': return 'assets/metro_icons/metro_7bis.svg';
      case '8': return 'assets/metro_icons/metro_8.svg';
      case '9': return 'assets/metro_icons/metro_9.svg';
      case '10': return 'assets/metro_icons/metro_10.svg';
      case '11': return 'assets/metro_icons/metro_11.svg';
      case '12': return 'assets/metro_icons/metro_12.svg';
      case '13': return 'assets/metro_icons/metro_13.svg';
      case '14': return 'assets/metro_icons/metro_14.svg';
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant?>(
      future: fetchRestaurant(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SizedBox(),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Restaurant introuvable')),
          );
        }
        final restaurant = snapshot.data!;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Espace pour la barre de statut du téléphone
                Container(
                  width: 390,
                  height: 47,
                  color: Colors.transparent,
                ),
                
                // Div pour le bouton précédent
                Container(
                  width: 390,
                  height: 47,
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/icon/precedent.png',
                        width: 50,
                        height: 48,
                      ),
                    ),
                  ),
                ),

                // Image slider with caching and back button
                if (restaurant.imageUrls.isNotEmpty)
                  Container(
                    height: 369,
                    margin: const EdgeInsets.only(left: 10),
                    child: PageView.builder(
                      controller: PageController(
                        viewportFraction: 0.85, // Pour voir un aperçu de la photo suivante
                      ),
                      itemCount: restaurant.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 314,
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: restaurant.imageUrls[index],
                              fit: BoxFit.cover,
                              cacheKey: restaurant.imageUrls[index],
                              placeholder: (_, __) => Container(
                                color: AppColors.lightGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.lightGrey,
                                child: const Icon(Icons.broken_image, size: 80),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + actions
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontFamily: 'InriaSans',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
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
                              icon: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: Icon(
                                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),

                        // Subtitle
                        if (restaurant.cuisines.isNotEmpty)
                          Text(
                            restaurant.cuisines.join(', '),
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
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
                                        const EdgeInsets.symmetric(horizontal: 16)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Faire une réservation',
                                    style: TextStyle(
                                      fontFamily: 'InriaSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
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
                                        const EdgeInsets.symmetric(horizontal: 16)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Menu',
                                    style: TextStyle(
                                      fontFamily: 'InriaSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

                        // Tags du restaurant
                        if (restaurant.types.isNotEmpty || restaurant.ambiance.isNotEmpty || 
                            restaurant.restrictions.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ...restaurant.types.map((t) => _buildTagChip(t)),
                              ...restaurant.ambiance.map((a) => _buildTagChip(a)),
                              ...restaurant.restrictions.map((r) => _buildTagChip(r)),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sections
                        if (restaurant.commentaire.isNotEmpty) ...[
                          Text(
                            'À propos', 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.commentaire, 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Horaires - afficher soit les horaires structurés soit les horaires textuels
                        if (restaurant.hoursStructured.keys.isNotEmpty) ...[
                          Text(
                            'Horaires', 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DynamicHoursWidget(hoursStructured: restaurant.hoursStructured),
                          const SizedBox(height: 12),
                        ] else if (restaurant.hours.isNotEmpty) ...[
                          Text(
                            'Horaires', 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.hours, 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (restaurant.stationNames.isNotEmpty) ...[
                          Text(
                            'Métro', 
                            style: const TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildMetroStations(restaurant),
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
