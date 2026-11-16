import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

/// Persists the user's chosen theme mode.
class ThemeController extends GetxController {
  ThemeController(this._storage);

  final LocalStorage _storage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getString(StorageKeys.themeMode);
    switch (saved) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }

  ThemeMode get current => themeMode.value;
}
