import 'package:hive/hive.dart';
import '../models/wishlist_item.dart';

/// A simple wrapper service around a Hive box that stores [WishlistItem]s.
/// Provides a toggle helper so the caller does not need to remember whether
/// an item is already present.
class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  /// Lazily‑opened box with the wishlist items.
  Box<WishlistItem> get _box => Hive.box<WishlistItem>('wishlist');

  List<WishlistItem> get items => _box.values.toList();

  bool isInWishlist(String id) => _box.containsKey(id);

  /// Adds the [item] if it is not present, otherwise removes it.
  void toggle(WishlistItem item) {
  final box = Hive.box<WishlistItem>('wishlist');
  print('TOGGLE: \${item.id}'); // 🔍 LOG
  if (box.containsKey(item.id)) {
    box.delete(item.id);
    print('USUNIĘTO z ulubionych: \${item.id}');
  } else {
    box.put(item.id, item);
    print('DODANO do ulubionych: \${item.id}');
  }
}
}
