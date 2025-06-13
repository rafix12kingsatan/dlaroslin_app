import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class WishlistItem {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String image;

  WishlistItem({
    required this.id,
    required this.title,
    required this.image,
  });
}

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 0;

  @override
  WishlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
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
