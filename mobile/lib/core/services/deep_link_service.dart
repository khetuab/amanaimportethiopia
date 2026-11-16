import 'package:get/get.dart';

import '../../features/shared/notifications/notifications_controller.dart';
import '../../routes/app_routes.dart';
import '../network/api_exception.dart';
import '../utils/error_handler.dart';

/// Handles a deep-link payload of the form:
///   ethiomarket://order/<orderId>
///   ethiomarket://request/<requestId>
///   ethiomarket://conversation/<conversationId>
///   ethiomarket://dispute/<orderId>
class DeepLinkService extends GetxService {
  void handle(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.isEmpty ? uri.pathSegments.firstOrNull : uri.host;
      final id = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : (uri.queryParameters['id'] ?? '');

      switch (host) {
        case 'order':
          _goOrder(id);
          return;
        case 'request':
          Get.toNamed(AppRoutes.requestDetail, arguments: id);
          return;
        case 'conversation':
          Get.toNamed(AppRoutes.conversations);
          return;
        case 'dispute':
          Get.toNamed(AppRoutes.disputeDetail, arguments: id);
          return;
      }
    } catch (e) {
      ErrorHandler.toast(ApiException(message: 'Invalid link'));
    }
  }

  void _goOrder(String id) {
    // Choose route based on current user's role (registered by AuthServiceRoleTag).
    // Fallback: buyer order detail.
    final role = Get.isRegistered<AuthServiceRoleTag>()
        ? Get.find<AuthServiceRoleTag>().role
        : 'buyer';
    final target = role == 'buyer'
        ? AppRoutes.buyerOrderDetail
        : AppRoutes.importerOrderDetail;
    Get.toNamed(target, arguments: id);
  }
}

// Needed import for extension .firstOrNull in older Dart — define it.
extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
