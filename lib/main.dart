import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'privacy_policy_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/wishlist_item.dart';
import 'services/wishlist_service.dart';
import 'screens/wishlist_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io';

const String kPrivacyUrl = 'https://dlaroslin.pl/cms/130/polityka-prywatnosci';
void main() async {
  if (kDebugMode) debugPrint('Android NDK Version: 27 (zgodność)');

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    AndroidWebViewController.enableDebugging(kDebugMode);
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
    return MaterialApp(
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  late final WebViewController _controller;

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addListener(() => setState(() {}));
    
    _animationController.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebViewScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Szukaj produktów...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  final query = value.trim();
                  if (query.isNotEmpty) {
                    _controller.loadRequest(Uri.parse('https://dlaroslin.pl/szukaj?phrase=${Uri.encodeComponent(query)}'));
                    setState(() {
                      _showSearch = false;
                    });
                  }
                },
              )
            : const Text('DlaRoślin'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                }
              });
            },
          ),
        ],
      ),

      
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 24),
                const Text(
                  'dlaroslin.pl',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF215A93),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 220,
                  child: const LinearProgressIndicator(
                    minHeight: 10,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF6DBE3E)),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                const Text(
                  'Zamów łatwo tutaj.\nDostarczymy skutecznie.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF215A93),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'dlaroslin.pl',
                style: TextStyle(
                  color: Color(0xFF215A93),
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  var _loadingProgress = 0;
  var _isLoading = true;
  var _hasError = false;
  var _isOffline = false;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setBackgroundColor(const Color(0x00000000))
..addJavaScriptChannel(
  'WishlistChannel',
  onMessageReceived: (JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final item = WishlistItem(
        id: data['id'].toString(),
        title: data['title'] ?? '',
        image: data['image'] ?? '',
      );
      WishlistService().toggle(item);
    } catch (e) {
      if (kDebugMode) debugPrint('Wishlist parse error: $e');
    }
  },
)

      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          final uri = Uri.parse(request.url);
          final bool allowedHost = uri.host == 'dlaroslin.pl' || uri.host.endsWith('.dlaroslin.pl');
          if (allowedHost) {
            return NavigationDecision.navigate;
          }
          // Otwarcie zewnętrznej przeglądarki dla pozostałych linków
          launchUrl(uri, mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
        
        onProgress: (progress) => setState(() => _loadingProgress = progress),
        onPageStarted: (url) => setState(() {
          _isLoading = true;
          _hasError = false;
          _isOffline = false;
        }),
        onPageFinished: (url) => setState(() => _isLoading = false),
        onWebResourceError: (error) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _isOffline = [-2, -6, -8, -10].contains(error.errorCode);
          });
          if (kDebugMode) debugPrint('WebView Error (${error.errorCode}): ${error.description}');
        },
      ))
      ..loadRequest(Uri.parse('https://dlaroslin.pl'))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36');
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _isOffline = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  void _openSearch() {
    setState(() {
      _hasError = false;
      _isOffline = false;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse('https://dlaroslin.pl/'));
  }
  void _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  
  Future<void> _toggleMenu() async {
    // Spróbuj najpierw zamknąć overlay (jeżeli otwarte)
    await _controller.runJavaScript(
      "document.querySelector('.mmenu__backdrop, .menu-backdrop, .mmenu-overlay')?.click();"
    );
    await Future.delayed(const Duration(milliseconds: 600));
    // Kliknij przycisk hamburgera
    await _controller.runJavaScript(
      "document.getElementById('hamburger')?.click();"
    );
  }

void _toggleWebMenu() {
    _controller.runJavaScript(r"""
      // Próba znalezienia przycisku menu
      const menuButton = document.querySelector('.hamburger, .menu-toggle, #menu-toggle, .navbar-toggler, [aria-label="Menu"], button[data-toggle="collapse"]');
      
      if (menuButton) {
        menuButton.click();
      }
    """);
  }


void _activateSearch() {
  _openSearch();
}



  void _goToHome() {
    _controller.loadRequest(Uri.parse('https://dlaroslin.pl'));
  }

  void _goToAccount() {
    final encodedUrl = Uri.encodeComponent('https://dlaroslin.pl/moje-konto');
    _controller.loadRequest(Uri.parse('https://dlaroslin.pl/logowanie?back=$encodedUrl'));
  }

  void _goToFavorites() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WishlistPage()));
  }

  void _goToCart() {
    _controller.loadRequest(Uri.parse('https://dlaroslin.pl/koszyk'));
  }

void _openPrivacyPolicy() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PrivacyPolicyScreen(url: kPrivacyUrl),
    ),
  );
}


@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}
  @override

  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        mini: true,
        tooltip: 'Polityka prywatności',
        child: const Icon(Icons.privacy_tip_outlined),
        onPressed: _openPrivacyPolicy,
      ),
      
      body: SafeArea(
        child: Stack(
          children: [
            if (!_hasError) WebViewWidget(
                controller: _controller,
                gestureRecognizers: {
                  Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                  ),
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
              ),
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOffline ? Icons.wifi_off : Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isOffline 
                          ? 'Brak połączenia internetowego'
                          : 'Nie można załadować strony',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _goBack,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Wróć'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Spróbuj ponownie'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFE0E0E0),
                color: Color(0xFF379A43),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFDDDDDD))),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: _goToHome,
              child: _BottomNavIcon(icon: "🏠", label: "Home"),
            ),
            GestureDetector(
              onTap: _toggleMenu,
              child: _BottomNavIcon(icon: "☰", label: "Menu"),
            ),
            GestureDetector(
              onTap: _activateSearch,
              child: _BottomNavIcon(icon: "🔍"),
            ),
            GestureDetector(
              onTap: _goToAccount,
              child: _BottomNavIcon(icon: "👤", label: "Konto"),
            ),
            GestureDetector(
              onTap: _goToFavorites,
              child: _BottomNavIcon(icon: "❤️", label: "Ulubione"),
            ),
            GestureDetector(
              onTap: _goToCart,
              child: Stack(
                children: [
                  _BottomNavIcon(icon: "🛒", label: "Koszyk"),
                  const Positioned(
                    right: 0,
                    top: 2,
                    child: _CartBadge(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final String icon;
  final String? label;
  const _BottomNavIcon({required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        if (label != null)
          Text(label!, style: const TextStyle(fontSize: 11, color: Color(0xFF333333))),
      ],
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          '0',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}