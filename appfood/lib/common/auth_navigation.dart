import 'package:flutter/material.dart';

import 'package:appfood/view/main_tabview/main_tabview.dart';

/// Sau đăng nhập / đăng ký — luôn vào app khách; admin vào **Khác → Quản trị**.
Future<void> replaceWithPostAuthHome(BuildContext context) async {
  if (!context.mounted) return;
  // Login/SignUp có thể nằm trong Navigator của tab — phải thay stack gốc của app.
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const MainTabView()),
    (route) => false,
  );
}
