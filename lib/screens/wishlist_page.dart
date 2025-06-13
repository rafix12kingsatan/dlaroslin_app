import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/wishlist_item.dart';
import '../services/wishlist_service.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _service = WishlistService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista życzeń'),
      ),
      body: ValueListenableBuilder<Box<WishlistItem>>(
        valueListenable: Hive.box<WishlistItem>('wishlist').listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();
          print('ULUBIONE: \${items.map((e) => e.id).toList()}'); // 🔍 LOG
          if (items.isEmpty) {
            return const Center(child: Text('Brak produktów na liście'));
          }

          return SizedBox.expand(
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                  title: Text(item.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _service.toggle(item);
                      });
                    },
                  ),
                  onTap: () async {
                    final url = Uri.parse('https://dlaroslin.pl/${item.id}');
                    if (await canLaunchUrl(url)) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}