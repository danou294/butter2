// lib/screens/restaurant_detail_page.dart

import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({Key? key, required this.restaurant})
      : super(key: key);

  Widget _buildChipsSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((e) => Chip(label: Text(e))).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = restaurant;

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Slider d'images
          if (r.imageUrls.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: r.imageUrls.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.network(
                    r.imageUrls[i],
                    width: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Adresse
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Expanded(child: Text(r.fullAddress)),
            ],
          ),

          const SizedBox(height: 12),

          // Téléphone
          if (r.phone.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 8),
                Text(r.phone),
              ],
            ),

          // Site web
          if (r.website.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 8),
                Flexible(child: Text(r.website)),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Horaires
          if (r.hours.isNotEmpty) ...[
            const Text('Horaires', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.hours),
            const SizedBox(height: 12),
          ],

          // Commentaire (À propos)
          if (r.commentaire.isNotEmpty) ...[
            const Text('À propos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(r.commentaire),
            const SizedBox(height: 12),
          ],

          // Type de restaurant
          _buildChipsSection('Catégories', r.types),

          // Cuisine
          _buildChipsSection('Cuisine', r.cuisines),

          // Ambiance
          _buildChipsSection('Ambiance', r.ambiance),

          // Restrictions alimentaires
          _buildChipsSection('Restrictions', r.restrictions),

          // Terrasse
          if (r.hasTerrace) ...[
            const Text('Terrasse', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (r.terraceLocs.isNotEmpty)
              Wrap(
                spacing: 6,
                children:
                    r.terraceLocs.map((t) => Chip(label: Text(t))).toList(),
              )
            else
              const Text('Terrasse disponible'),
          ],
        ],
      ),
    );
  }
}
