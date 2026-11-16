
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/localization/localization_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/app_offline_banner.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class EthioMarketApp extends StatelessWidget {
  const EthioMarketApp({super.key, required this.localization});

  final LocalizationService localization;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[APP DEBUG] $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    _log('EthioMarketApp.build() started');

    final themeCtrl = Get.find<ThemeController>();
    _log('ThemeController found');

    return Obx(() {
      final mode = themeCtrl.themeMode.value;
      _log('Building GetMaterialApp; themeMode=$mode');

      return GetMaterialApp(
        title: 'EthioMarket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        translations: localization,
        locale: localization.initialLocale,
        fallbackLocale: const Locale('en'),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 260),
        initialBinding: null,

        // Log route changes and navigation errors.
        routingCallback: (routing) {
          _log(
            'ROUTE: current=${routing?.current}, '
                'previous=${routing?.previous}, '
                'isBack=${routing?.isBack}',
          );
        },

        builder: (context, child) {
          _log(
            'GetMaterialApp.builder called; '
                'child=${child?.runtimeType}',
          );

          return Column(
            children: [
              const AppOfflineBanner(),
              Expanded(
                child: child ?? const SizedBox.shrink(),
              ),
            ],
          );
        },
      );
    });
  }
}
