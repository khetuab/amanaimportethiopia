import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/localization/localization_service.dart';
import '../../core/services/session_guard.dart';
import '../../routes/app_routes.dart';

/// One selectable language shown on the first-run gate.
class AppLanguage {
  const AppLanguage(this.code, this.tag, this.native, this.english);

  /// Locale code — matches [LocalizationService.supportedLocales].
  final String code;

  /// Short tag rendered in the leading tile ("EN", "አማ", "ع").
  final String tag;

  /// Native name — always shown in its own script, never translated.
  final String native;

  /// English name shown as the secondary label.
  final String english;
}

class LanguageController extends GetxController {
  LanguageController(this._loc, this._guard);

  final LocalizationService _loc;
  final SessionGuard _guard;

  /// The three supported languages, in display order.
  static const List<AppLanguage> languages = [
    AppLanguage('en', 'EN', 'English', 'English'),
    AppLanguage('am', 'አማ', 'አማርኛ', 'Amharic'),
    AppLanguage('ar', 'ع', 'العربية', 'Arabic'),
  ];

  /// Nothing is preselected — the user must make a conscious choice.
  final RxString selected = ''.obs;
  final RxBool busy = false.obs;

  /// Applies the locale immediately so the whole screen previews in the
  /// chosen language. The choice is only persisted on [confirm].
  void select(String code) {
    if (selected.value == code) return;
    selected.value = code;
    Get.updateLocale(Locale(code));
  }

  /// Persists the choice via [LocalizationService.changeLanguage], then
  /// lets [SessionGuard] decide the next stop — onboarding on a true
  /// first run, login / home shell for users updating from an older
  /// build who had already onboarded.
  Future<void> confirm() async {
    if (selected.value.isEmpty || busy.value) return;
    busy.value = true;
    await _loc.changeLanguage(selected.value);
    busy.value = false;
    Get.offAllNamed(_guard.initialRoute());
  }
}
