import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wishlist_item.dart';
import '../services/wishlist_service.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<WishlistItem>('wishlist');
    return Scaffold(
      appBar: AppBar(title: const Text('Ulubione')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<WishlistItem> value, _) {
          if (value.isEmpty) {
            return const Center(child: Text('Brak zapisanych produktów'));
          }
          return ListView.separated(
            itemCount: value.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = value.getAt(index)!;
              return ListTile(
                leading: Image.network(
                  item.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(item.title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => WishlistService().toggle(item),
                ),
                onTap: () async {
                  final url = Uri.tryParse('https://dlaroslin.pl/produkt/${item.id}');
                  if (url != null && await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
