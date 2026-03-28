import 'dart:convert';
import 'dart:io';

class Globs {
  /// Emulator Android → máy host; iOS Simulator / desktop → loopback IPv4 (tránh localhost → ::1 không khớp server).
  static const String loopbackHost = '127.0.0.1';
  static const String androidEmulatorHost = '10.0.2.2';
  /// Trùng backend `.env` PORT — dùng 5050 để tránh xung đột AirPlay (macOS) trên cổng 5000 → 403.
  static const String port = '5050';

  /// Máy thật: `flutter run --dart-define=API_HOST=192.168.1.5` (IP Wi‑Fi của máy chạy Node).
  static const String _apiHostOverride = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_apiHostOverride.isNotEmpty) {
      return 'http://$_apiHostOverride:$port';
    }
    if (Platform.isAndroid) {
      return 'http://$androidEmulatorHost:$port';
    }
    return 'http://$loopbackHost:$port';
  }

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';
  static String get socialLoginUrl => '$baseUrl/api/auth/social';
  static String get profileUrl => '$baseUrl/api/auth/profile';
  static String get forgotPasswordUrl => '$baseUrl/api/auth/forgot-password';
  static String get resetPasswordUrl => '$baseUrl/api/auth/reset-password';
  static String get itemsUrl => '$baseUrl/api/food/items';
  static String get searchUrl => '$baseUrl/api/food/search';
  static String get categoriesUrl => '$baseUrl/api/food/categories';
  static String get checkoutUrl => '$baseUrl/api/food/checkout';

  /// JSON `{ "message": "..." }` hoặc chuỗi thường từ server (vd. 500).
  static String apiErrorMessage(String body, {String fallback = 'Lỗi'}) {
    final t = body.trim();
    if (t.isEmpty) return fallback;
    try {
      final data = jsonDecode(t);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return t.length > 200 ? fallback : t;
  }
}
