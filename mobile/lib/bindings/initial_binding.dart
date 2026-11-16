// lib/bindings/initial_binding.dart
import 'package:get/get.dart';

import '../core/localization/localization_service.dart';
import '../core/network/dio_client.dart';
import '../core/services/auth_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/deep_link_service.dart';
import '../core/services/fcm_service.dart';
import '../core/services/local_notification_service.dart';
import '../core/services/notifications_service.dart';
import '../core/services/session_guard.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../core/theme/theme_controller.dart';
import '../data/repositories/notification_repository.dart';
import '../features/shared/notifications/notifications_controller.dart';

class InitialBinding extends Bindings {
  InitialBinding({
    required this.secureStorage,
    required this.localStorage,
    required this.dioClient,
  });

  final SecureStorage secureStorage;
  final LocalStorage localStorage;
  final DioClient dioClient;

  @override
  void dependencies() {
    // Infra (permanent)
    Get.put<SecureStorage>(secureStorage, permanent: true);
    Get.put<LocalStorage>(localStorage, permanent: true);
    Get.put<DioClient>(dioClient, permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<ThemeController>(ThemeController(localStorage), permanent: true);
    Get.put(NotificationRepository(dioClient));
    Get.put<LocalizationService>(LocalizationService(localStorage), permanent: true);
    Get.put(
      NotificationsService(
        Get.find<NotificationRepository>(),
        Get.find<LocalNotificationService>(),
      ),
      permanent: true,
    );

    // Services (permanent)
    Get.put<AuthService>(AuthService(dioClient, secureStorage), permanent: true);
    Get.put<SessionGuard>(
      SessionGuard(Get.find<AuthService>(), localStorage),
      permanent: true,
    );
    Get.put<DeepLinkService>(DeepLinkService(), permanent: true);
    Get.put<FcmService>(FcmService(dioClient, localStorage), permanent: true);
    Get.put<AuthServiceRoleTag>(AuthServiceRoleTag(), permanent: true);
  }
}