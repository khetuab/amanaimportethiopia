import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/session_guard.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._guard);
  final SessionGuard _guard;

  final PageController pageController = PageController();
  final RxInt index = 0.obs;

  static const int lastIndex = 2;

  void next() {
    if (index.value == lastIndex) {
      _finish();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void previous() {
    if (index.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void skip() => _finish();

  Future<void> _finish() async {
    await _guard.completeOnboarding();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
