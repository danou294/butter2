import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant un restaurant, adapté à la structure Firestore
class Restaurant {
  final String id;
  final String name;
  final String rawName;

  // Adresse
  final String fullAddress;
  final int arrondissement;

  // Commentaires et horaires
  final String commentaire;
  final String hours;
  final Map<String, dynamic> hoursStructured;

  // Contact
  final String phone;
  final String website;
  final String reservationLink;
  final String instagram;

  // Liens Maps et menu
  final String googleLink;
  final String menuLink;

  // Catégories multi-choix
  final List<String> types;
  final List<String> moments;
  final List<String> lieux;
  final List<String> ambiance;
  final String priceRange;
  final List<String> cuisines;
  final List<String> restrictions;

  // Terrasse
  final bool hasTerrace;
  final List<String> terraceLocs;

  // Stations de métro
  final List<String> stationsMetro;
  final List<Map<String, dynamic>> stationsMetroStructured;

  // Informations complémentaires
  final String moreInfo;

  // Médias
  final String? logoUrl;
  final List<String> imageUrls;

  final String specialiteTag;
  final String tag;

  /// Map label→codes postaux pour les arrondissements
  static const Map<String, List<String>> arrondissementMap = {
    '1e':  ['75001'],  '2e':  ['75002'],  '3e':  ['75003'],  '4e':  ['75004'],
    '5e':  ['75005'],  '6e':  ['75006'],  '7e':  ['75007'],  '8e':  ['75008'],
    '9e':  ['75009'], '10e': ['75010'], '11e': ['75011'], '12e': ['75012'],
    '13e': ['75013'], '14e': ['75014'], '15e': ['75015'], '16e': ['75016', '75116'],
    '17e': ['75017'], '18e': ['75018'], '19e': ['75019'], '20e': ['75020'],
  };

  /// Map label→code postal pour les communes
  static const Map<String, String> communeMap = {
    'Boulogne':    '92100',
    'Levallois':   '92300',
    'Neuilly':     '92200',
    'Charenton':   '94220',
    'Saint-Mandé': '94160',
    'Saint-Ouen':  '93400',
    'Saint-Cloud': '92210',
  };

  /// Groupes d'arrondissements/communes par direction (labels, pas codes postaux)
  static const Map<String, List<String>> directionGroups = {
    'Ouest':  [
      '8e', '15e', '16e', '17e', 'Boulogne', 'Levallois', 'Neuilly', 'Saint-Cloud', 'Saint-Ouen'
    ],
    'Centre': [
      '1e', '2e', '3e', '4e', '5e', '6e', '7e', '9e', '10e', '14e', '18e'
    ],
    'Est':    [
      '11e', '12e', '13e', '19e', '20e', 'Charenton'
    ],
  };

  Restaurant({
    required this.id,
    required this.name,
    this.rawName = '',
    required this.fullAddress,
    required this.arrondissement,
    required this.commentaire,
    required this.hours,
    required this.hoursStructured,
    required this.phone,
    required this.website,
    required this.reservationLink,
    required this.instagram,
    required this.googleLink,
    required this.menuLink,
    required this.types,
    required this.moments,
    required this.lieux,
    required this.ambiance,
    required this.priceRange,
    required this.cuisines,
    required this.restrictions,
    required this.hasTerrace,
    required this.terraceLocs,
    required this.stationsMetro,
    required this.stationsMetroStructured,
    this.moreInfo = '',
    this.logoUrl,
    this.imageUrls = const [],
    this.specialiteTag = '',
    this.tag = '',
  });

  /// Crée une instance depuis Firestore
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Restaurant.fromMap(doc.id, data);
  }

  /// Crée une instance depuis un Map
  factory Restaurant.fromMap(String id, Map<String, dynamic> data) {
    List<String> toList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.isNotEmpty) {
        // support simple comma-separated strings
        return v.split(',').map((e) => e.trim()).toList();
      }
      if (v is Map) {
        // map of bools
        return v.entries.where((e) => e.value == true).map((e) => e.key.toString()).toList();
      }
      return [];
    }

    String getAddressField(String key) {
      final addr = data['address'];
      if (addr is Map && addr[key] is String) return addr[key] as String;
      return '';
    }
    int getAddressIntField(String key) {
      final addr = data['address'];
      if (addr is Map && addr[key] is int) return addr[key] as int;
      if (addr is Map && addr[key] is num) return (addr[key] as num).toInt();
      if (data[key] is int) return data[key] as int;
      if (data[key] is num) return (data[key] as num).toInt();
      return 0;
    }
    String getContactField(String key) {
      final c = data['contact'];
      if (c is Map && c[key] is String) return c[key] as String;
      return '';
    }
    String getMapsField(String key) {
      final m = data['maps'];
      if (m is Map && m[key] is String) return m[key] as String;
      return '';
    }

    // Gestion sécurisée de l'arrondissement
    int getArrondissement() {
      try {
        // Essayer d'abord le champ direct
        if (data['arrondissement'] != null) {
          if (data['arrondissement'] is int) {
            return data['arrondissement'] as int;
          }
          if (data['arrondissement'] is num) {
            return (data['arrondissement'] as num).toInt();
          }
          if (data['arrondissement'] is String) {
            // Si c'est une string comme "75010", extraire le numéro
            final str = data['arrondissement'] as String;
            if (str.startsWith('750')) {
              return int.tryParse(str.substring(3)) ?? 0;
            }
            return int.tryParse(str) ?? 0;
          }
        }
        
        // Essayer dans le sous-objet address
        return getAddressIntField('arrondissement');
      } catch (e) {
        return 0;
      }
    }

    // Gestion sécurisée de l'adresse complète
    String _getFullAddress(Map<String, dynamic> data) {
      try {
        final address = data['address'];
        
        // Nouveau format : address est une String
        if (address is String) {
          return address;
        }
        
        // Ancien format : address est un Map avec 'full'
        if (address is Map && address['full'] is String) {
          return address['full'] as String;
        }
        
        return '';
      } catch (e) {
        return '';
      }
    }

    // Parse les stations de métro (format ancien : liste de strings)
    List<String> _parseStationsMetro(dynamic stationsData) {
      if (stationsData == null) return [];
      
      // Si c'est une liste
      if (stationsData is List) {
        // Vérifier si c'est le nouveau format (liste d'objets)
        if (stationsData.isNotEmpty && stationsData.first is Map) {
          // Nouveau format : extraire les noms des stations
          return stationsData
              .where((station) => station is Map && station['station'] != null)
              .map((station) => station['station'].toString())
              .toList();
        } else {
          // Ancien format : liste de strings
          return stationsData.map((e) => e.toString()).toList();
        }
      }
      
      return [];
    }

    // Parse les stations de métro structurées (nouveau format : liste d'objets)
    List<Map<String, dynamic>> _parseStationsMetroStructured(dynamic stationsData) {
      if (stationsData == null) return [];
      
      // Si c'est une liste d'objets (nouveau format)
      if (stationsData is List && stationsData.isNotEmpty && stationsData.first is Map) {
        return stationsData.cast<Map<String, dynamic>>().toList();
      }
      
      return [];
    }

    return Restaurant(
      id: id,
      name: data['name'] as String? ?? '',
      rawName: data['raw_name'] as String? ?? '',
      fullAddress: _getFullAddress(data),
      arrondissement: getArrondissement(),
      commentaire: data['more_info'] as String? ?? '',
      hours: data['hours'] as String? ?? '',
      hoursStructured: data['hours_structured'] as Map<String, dynamic>? ?? {},
      phone: data['phone'] as String? ?? '',
      website: data['website'] as String? ?? '',
      reservationLink: data['reservation_link'] as String? ?? '',
      instagram: data['instagram_link'] as String? ?? '',
      googleLink: data['google_link'] as String? ?? '',
      menuLink: data['lien_menu'] as String? ?? '',
      types: toList(data['types']),
      moments: toList(data['moments']),
      lieux: toList(data['lieux']),
      ambiance: toList(data['ambiance']),
      priceRange: data['price_range'] as String? ?? '',
      cuisines: toList(data['cuisines']),
      restrictions: toList(data['restrictions']),
      hasTerrace: data['has_terrace'] as bool? ?? false,
      terraceLocs: toList(data['terrace_locs']),
      stationsMetro: _parseStationsMetro(data['stations_metro']),
      stationsMetroStructured: _parseStationsMetroStructured(data['stations_metro']),
      moreInfo: data['more_info'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      imageUrls: toList(data['imageUrls']),
      specialiteTag: data['specialite_tag'] as String? ?? '',
      tag: data['tag'] as String? ?? '',
    );
  }

  /// Sérialise en Map pour Firestore
  Map<String, dynamic> toJson() {
    Map<String, bool> boolMap(List<String> keys) =>
        {for (var k in keys) k: true};

    return {
      'name': name,
      'raw_name': rawName,
      'address': {
        'full': fullAddress,
        'arrondissement': arrondissement,
      },
      'commentaire': commentaire,
      'hours': hours,
      'hours_structured': hoursStructured,
      'contact': {
        'phone': phone,
        'website': website,
        'reservation_link': reservationLink,
        'instagram': instagram,
      },
      'maps': {
        'google_link': googleLink,
        'menu_link': menuLink,
      },
      'types': boolMap(types),
      'moments': boolMap(moments),
      'lieux': boolMap(lieux),
      'ambiance': boolMap(ambiance),
      'price_range': priceRange,
      'cuisines': boolMap(cuisines),
      'restrictions': boolMap(restrictions),
      'has_terrace': hasTerrace,
      'terrace_locs': boolMap(terraceLocs),
      'stations_metro': boolMap(stationsMetro),
      'stations_metro_structured': stationsMetroStructured,
      'more_info': moreInfo,
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'specialite_tag': specialiteTag,
      'tag': tag,
    };
  }

  // Getters utilitaires pour les horaires structurés
  String? getLunchHours(String day) => hoursStructured[day]?['service_1'];
  String? getDinnerHours(String day) => hoursStructured[day]?['service_2'];
  bool isClosed(String day) => hoursStructured[day]?['closed'] == true;

  // Getter pour les noms des stations de métro
  List<String> get stationNames {
    if (stationsMetroStructured.isNotEmpty) {
      return stationsMetroStructured
          .map((station) => station['station'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }
    return stationsMetro;
  }
}
