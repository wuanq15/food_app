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
  static String get restaurantsUrl => '$baseUrl/api/food/restaurants';
  static String get itemsUrl => '$baseUrl/api/food/items';
  static String get searchUrl => '$baseUrl/api/food/search';
  static String get categoriesUrl => '$baseUrl/api/food/categories';
  /// Mã ưu đãi đang bật (public, không cần JWT).
  static String get publicVouchersUrl => '$baseUrl/api/food/vouchers';
  static String get checkoutUrl => '$baseUrl/api/food/checkout';
  static String get myOrdersUrl => '$baseUrl/api/food/my-orders';

  static String get adminOrdersUrl => '$baseUrl/api/admin/orders';
  static String adminOrderPatchUrl(int id) => '$baseUrl/api/admin/orders/$id';
  static String get adminRestaurantsUrl => '$baseUrl/api/admin/restaurants';
  static String adminRestaurantUrl(String id) => '$baseUrl/api/admin/restaurants/$id';
  static String get adminCategoriesUrl => '$baseUrl/api/admin/categories';
  static String adminCategoryUrl(String id) => '$baseUrl/api/admin/categories/$id';
  static String get adminItemsUrl => '$baseUrl/api/admin/items';
  static String adminItemUrl(String id) => '$baseUrl/api/admin/items/$id';
  static String get adminVouchersUrl => '$baseUrl/api/admin/vouchers';
  static String adminVoucherDetailUrl(String code) =>
      '$baseUrl/api/admin/vouchers/${Uri.encodeComponent(code)}';
  static String get adminUsersUrl => '$baseUrl/api/admin/users';
  static String adminUserPatchUrl(int id) => '$baseUrl/api/admin/users/$id';

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
