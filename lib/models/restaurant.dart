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

  // Informations complémentaires
  final String moreInfo;

  // Médias
  final String? logoUrl;
  final List<String> imageUrls;

  final String specialiteTag;
  final String tag;

  /// Map label→code postal pour les arrondissements
  static const Map<String, String> arrondissementMap = {
    '1e':  '75001',  '2e':  '75002',  '3e':  '75003',  '4e':  '75004',
    '5e':  '75005',  '6e':  '75006',  '7e':  '75007',  '8e':  '75008',
    '9e':  '75009', '10e': '75010', '11e': '75011', '12e': '75012',
    '13e': '75013', '14e': '75014', '15e': '75015', '16e': '75016',
    '17e': '75017', '18e': '75018', '19e': '75019', '20e': '75020',
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

  /// Groupes de codes postaux par direction
  static const Map<String, List<String>> directionGroups = {
    'Ouest':  ['75015','75016','75017','75018','92200','92210','92300'],
    'Centre': ['75001','75002','75003','75004','75005','75006','75007','75008','75009'],
    'Est':    ['75010','75011','75012','75013','75014','75019','75020','93400','94160','94220'],
  };

  Restaurant({
    required this.id,
    required this.name,
    this.rawName = '',
    required this.fullAddress,
    required this.arrondissement,
    required this.commentaire,
    required this.hours,
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

    return Restaurant(
      id: id,
      name: data['name'] as String? ?? '',
      rawName: data['raw_name'] as String? ?? '',
      fullAddress: getAddressField('full'),
      arrondissement: getAddressIntField('arrondissement'),
      commentaire: data['commentaire'] as String? ?? '',
      hours: data['hours'] as String? ?? '',
      phone: getContactField('phone'),
      website: getContactField('website'),
      reservationLink: getContactField('reservation_link'),
      instagram: getContactField('instagram'),
      googleLink: getMapsField('google_link'),
      menuLink: getMapsField('menu_link'),
      types: toList(data['types']),
      moments: toList(data['moments']),
      lieux: toList(data['lieux']),
      ambiance: toList(data['ambiance']),
      priceRange: data['price_range'] as String? ?? '',
      cuisines: toList(data['cuisines']),
      restrictions: toList(data['restrictions']),
      hasTerrace: data['has_terrace'] as bool? ?? false,
      terraceLocs: toList(data['terrace_locs']),
      stationsMetro: toList(data['stations_metro']),
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
      'more_info': moreInfo,
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
      'specialite_tag': specialiteTag,
      'tag': tag,
    };
  }
}
