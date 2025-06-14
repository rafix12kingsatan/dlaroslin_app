import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class WishlistItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String image;

  WishlistItem({
    required this.id,
    required this.title,
    required this.image,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WishlistItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 0;

  @override
  WishlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return WishlistItem(
      id: fields[0] as String,
      title: fields[1] as String,
      image: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.image);
  }
}
