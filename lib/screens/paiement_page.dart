import 'package:flutter/material.dart';
import '../services/purchase_service.dart';

class PaiementPage extends StatefulWidget {
  const PaiementPage({Key? key}) : super(key: key);

  @override
  State<PaiementPage> createState() => _PaiementPageState();
}

class _PaiementPageState extends State<PaiementPage> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    setState(() => _isLoading = true);
    await _purchaseService.initialize();
    setState(() => _isLoading = false);
  }

  Future<void> _handlePurchase(String productId) async {
    try {
      setState(() => _isLoading = true);
      await _purchaseService.purchaseSubscription(productId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'achat: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abonnement Premium'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<PurchaseDetails>>(
              stream: _purchaseService.purchaseStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Gérer les achats ici si nécessaire
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium, size: 64, color: Colors.amber),
                      SizedBox(height: 24),
                      Text(
                        'Passe à Butter Premium !',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Débloque toutes les fonctionnalités exclusives',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      ..._purchaseService.products.map((product) {
                        final bool isYearly = product.id == 'premium_yearly';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () => _handlePurchase(product.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isYearly ? 'Abonnement Annuel' : 'Abonnement Mensuel',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  product.price,
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (isYearly) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Économisez 20%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16),
                      Text(
                        'Annulez à tout moment',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 