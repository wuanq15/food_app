import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appfood/common/globs.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String type1;
  final String type2;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final bool isOpen;
  final String deliveryTime;
  final double deliveryFee;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.type1,
    required this.type2,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.category = '',
    this.isOpen = true,
    this.deliveryTime = '25–35 phút',
    this.deliveryFee = 15000,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final type1 = json['type1']?.toString() ?? '';
    final open = json['is_open'];
    final isOpen = open == null
        ? true
        : (open == true || open == 1 || open == '1' || open == 'true');
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type1: type1,
      type2: json['type2'] ?? '',
      imageUrl: json['image'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
      category: json['category']?.toString() ?? type1,
      isOpen: isOpen,
      deliveryTime: json['delivery_time']?.toString() ?? '25–35 phút',
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '') ??
          15000,
    );
  }

  static Future<List<RestaurantModel>> fetchAll() async {
    try {
      final url = Uri.parse('${Globs.baseUrl}/api/food/restaurants');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => RestaurantModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
