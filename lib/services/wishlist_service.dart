import 'package:hive_flutter/hive_flutter.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  static final WishlistService _singleton = WishlistService._internal();
  factory WishlistService() => _singleton;
  WishlistService._internal();

  Box<WishlistItem> get _box => Hive.box<WishlistItem>('wishlist');

  List<WishlistItem> get items => _box.values.toList(growable: false);

  bool contains(WishlistItem item) => _box.containsKey(item.id);

  void toggle(WishlistItem item) {
    if (contains(item)) {
      _box.delete(item.id);
    } else {
      _box.put(item.id, item);
    }
  }

  void clear() => _box.clear();
}
