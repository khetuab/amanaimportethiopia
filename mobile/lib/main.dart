import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';
import 'bindings/initial_binding.dart';
import 'core/config/env.dart';
import 'core/localization/localization_service.dart';
import 'core/network/dio_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/secure_storage.dart';
import 'features/shared/notifications/notifications_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => LocalNotificationService().init(), permanent: true);
  // System chrome
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Env
  await Env.load();

  // 2. Storage
  final secure = SecureStorage();
  final local = await LocalStorage.create();

  // 3. Localization preload
  await LocalizationService.preload();

  // 4. Network
  final dioClient = await DioClient.create(secure);

  // 5. Bootstrap DI
  Get.put<LocalStorage>(local, permanent: true);
  Get.put<SecureStorage>(secure, permanent: true);

  final initialBinding = InitialBinding(
    secureStorage: secure,
    localStorage: local,
    dioClient: dioClient,
  );
  initialBinding.dependencies();

  // 6. Restore session if tokens exist
  await Get.find<AuthService>().restoreSession();
  // TEMPORARY — verify the network layer end-to-end


  Get.find<AuthServiceRoleTag>().role = Get.find<AuthService>().role;
  await Get.find<FcmService>().init();

  // 7. Build localization service
  final locService = LocalizationService(local);

  await initializeDateFormatting('en');
  await initializeDateFormatting('am');
  await initializeDateFormatting('ar');

  runApp(EthioMarketApp(localization: locService));
}
