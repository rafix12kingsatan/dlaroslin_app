# Flutter & WebView keep rules
-keep class io.flutter.** { *; }
-keep class android.webkit.WebView { *; }
-keep class android.webkit.WebSettings { *; }
# Keep Google Play Core / SplitCompat
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**
