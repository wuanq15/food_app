import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lưu JWT sau đăng nhập; gửi kèm API (profile, đặt hàng, lịch sử đơn).
class AuthStore {
  static const _kToken = 'auth_jwt';

  static Future<void> setToken(String? token) async {
    final p = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await p.remove(_kToken);
    } else {
      await p.setString(_kToken, token);
    }
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
  }

  static Future<void> saveTokenFromResponseBody(String body) async {
    try {
      final m = jsonDecode(body);
      if (m is Map<String, dynamic> && m['token'] is String) {
        await setToken(m['token'] as String);
      }
    } catch (_) {}
  }

  static Future<Map<String, String>> authHeaders({
    bool jsonContent = false,
  }) async {
    final h = <String, String>{};
    if (jsonContent) {
      h['Content-Type'] = 'application/json';
    }
    final t = await getToken();
    if (t != null && t.isNotEmpty) {
      h['Authorization'] = 'Bearer $t';
    }
    return h;
  }
}
