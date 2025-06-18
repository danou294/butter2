import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Set<String> _productIds = {'premium_monthly', 'premium_yearly'};
  List<ProductDetails> _products = [];

  // Getters
  List<ProductDetails> get products => _products;
  Future<bool> get isAvailable => _inAppPurchase.isAvailable();

  // Initialisation des produits
  Future<void> initialize() async {
    if (await isAvailable) {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('Produits non trouvés: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
    }
  }

  // Acheter un abonnement
  Future<void> purchaseSubscription(String productId) async {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Produit non trouvé: $productId'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Erreur lors de l\'achat: $e');
      rethrow;
    }
  }

  // Écouter les mises à jour des achats
  Stream<List<PurchaseDetails>> get purchaseStream => 
      _inAppPurchase.purchaseStream;
} 