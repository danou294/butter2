import 'package:flutter/material.dart';

class PaiementPage extends StatelessWidget {
  const PaiementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abonnement Premium'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
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
                'Débloque toutes les fonctionnalités exclusives pour seulement 4,99€/mois.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Ici tu simuleras la souscription (à remplacer par le vrai paiement plus tard)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Merci pour ton abonnement !')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('S’abonner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 