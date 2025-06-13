
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../models/wishlist_item.dart';

/// A simple reusable list of products with aggressive pre‑caching.
class ProductList extends StatelessWidget {
  final List<WishlistItem> items;

  const ProductList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Brak produktów do wyświetlenia'));
    }

    return RepaintBoundary(
      child: ListView.builder(
      cacheExtent: 1000, // 🔧 preloaduj 1000px
      physics: Platform.isIOS
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return ListTile(
          leading: Image.network(
            item.image,
            cacheWidth: 300,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
          title: Text(item.title),
          subtitle: Text('ID: ${item.id}'),
        );
      },
      ),
    );
  }
}