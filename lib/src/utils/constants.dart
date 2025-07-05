import 'package:flutter/material.dart';

class MdUserPickLocationGoogleMapConfig {
  static String _apiKey = '';
  static String _baseUrl = '';
  static String _fontFamily = '';
  static Color? _primaryColor;
  static void initialize({
    required String apiKey,
    Color? primaryColor,
    String? fontFamily,
    required String baseUrl,
  }) async {
    _apiKey = apiKey;
    _primaryColor = primaryColor ?? const Color(0xffD60020);
    _baseUrl = baseUrl;
    _fontFamily = fontFamily ?? 'Hanimation Arabic';
  }

  static String get apiKey => _apiKey;
  static String get baseUrl => _baseUrl;
  static String get fontFamily => _fontFamily;
  static Color? get primaryColor => _primaryColor;
}
