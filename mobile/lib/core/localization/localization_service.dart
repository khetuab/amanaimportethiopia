import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

class LocalizationService extends Translations {
  LocalizationService(this._storage);

  final LocalStorage _storage;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
    Locale('ar'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': _loadSync('en'),
    'am': _loadSync('am'),
    'ar': _loadSync('ar'),
  };

  static final Map<String, Map<String, String>> _cache = {};

  /// GetX only substitutes "@name" placeholders, so convert "{name}" to "@name".
  static String _toGetx(String v) => v.replaceAllMapped(
    RegExp(r'\{(\w+)\}'),
        (m) => '@${m[1]}',
  );

  static Future<void> preload() async {
    for (final locale in supportedLocales) {
      final jsonStr = await rootBundle.loadString(
        'lib/core/localization/translations/${locale.languageCode}.json',
      );
      final Map<String, dynamic> raw = json.decode(jsonStr);
      _cache[locale.languageCode] = raw.map(
            (k, v) => MapEntry(k, _toGetx(v.toString())),
      );
    }
  }

  Map<String, String> _loadSync(String code) => _cache[code] ?? {};

  String _initialLanguage() {
    final saved = _storage.getString(StorageKeys.languageCode);
    if (saved != null && supportedLocales.any((l) => l.languageCode == saved)) {
      return saved;
    }
    return 'en';
  }

  Locale get initialLocale => Locale(_initialLanguage());

  Future<void> changeLanguage(String code) async {
    if (!supportedLocales.any((l) => l.languageCode == code)) return;
    await _storage.setString(StorageKeys.languageCode, code);
    Get.updateLocale(Locale(code));
  }
}