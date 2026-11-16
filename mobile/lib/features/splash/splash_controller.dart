import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/session_guard.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this._auth, this._guard) {
    debugPrint('[SPLASH DEBUG] Controller constructed');
  }

  final AuthService _auth;
  final SessionGuard _guard;

  /// Minimum time the animation needs to play (boat + title + tagline).
  static const Duration _minDuration = Duration(milliseconds: 5400);

  @override
  void onInit() {
    super.onInit();
    debugPrint('[SPLASH DEBUG] onInit called');
    _boot();
  }

  Future<void> _boot() async {
    debugPrint('[SPLASH DEBUG] _boot entered');

    try {
      // Run the animation timer and session restore in parallel, so the
      // user waits for whichever is slower instead of both added together.
      await Future.wait<void>([
        Future<void>.delayed(_minDuration),
        _restoreSession(),
      ]);
      debugPrint('[SPLASH DEBUG] Animation + startup completed');

      if (isClosed) return;

      final target = _guard.initialRoute();
      debugPrint('[SPLASH DEBUG] Target route: $target');
      Get.offAllNamed(target);
    } catch (e, stackTrace) {
      debugPrint('[SPLASH DEBUG] Startup error: $e');
      debugPrintStack(stackTrace: stackTrace);
      // Never leave the user stuck on the splash screen.
      if (!isClosed) Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _restoreSession() async {
    try {
      if (!_auth.isAuthenticated) {
        debugPrint('[SPLASH DEBUG] Restoring session');
        await _auth.restoreSession();
        debugPrint('[SPLASH DEBUG] Session restored');
      }
    } catch (e) {
      // A failed restore just means "not signed in"; the guard decides the route.
      debugPrint('[SPLASH DEBUG] Session restore failed: $e');
    }
  }
}