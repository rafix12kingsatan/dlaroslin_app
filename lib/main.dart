import 'splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/wishlist_item.dart';
import 'services/wishlist_service.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    AndroidWebViewController.enableDebugging(false);
  }

  await Hive.initFlutter();
  Hive.registerAdapter(WishlistItemAdapter());
  await Hive.openBox<WishlistItem>('wishlist');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}