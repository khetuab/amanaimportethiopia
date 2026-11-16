import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/notifications_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../routes/app_routes.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repo);
  final NotificationRepository _repo;
  final _svc = Get.find<NotificationsService>();

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  RxList<NotificationModel> get items => _svc.items;
  RxInt get unread => _svc.unread;

  @override
  void onInit() {
    super.onInit();
    _startAfterAuthReady();
  }

  Future<void> _startAfterAuthReady() async {
    final auth = Get.find<AuthService>();
    for (var i = 0; i < 30 && !auth.isAuthenticated; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (!auth.isAuthenticated) {
      loading.value = false;
      return;
    }
    await load();
  }

  Future<void> load() async {
    if (!Get.find<AuthService>().isAuthenticated) return;
    loading.value = true;
    error.value = null;
    try {
      await _svc.refresh(throwOnError: true);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> markRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      await _repo.markRead(n.id);
      await load();
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllRead();
      await load();
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  void openTarget(NotificationModel n) async {
    await markRead(n);
    final orderId = n.data['orderId']?.toString();
    final convId = n.data['conversationId']?.toString();

    if (orderId != null && orderId.isNotEmpty) {
      final role = Get.isRegistered<AuthServiceRoleTag>()
          ? Get.find<AuthServiceRoleTag>().role
          : 'buyer';
      final target = role == 'buyer'
          ? AppRoutes.buyerOrderDetail
          : AppRoutes.importerOrderDetail;
      Get.toNamed(target, arguments: orderId);
      return;
    }
    if (convId != null && convId.isNotEmpty) {
      Get.toNamed(AppRoutes.conversations);
    }
  }
}

/// Small helper to avoid a hard dependency cycle on AuthService.
/// Registered in InitialBinding.
class AuthServiceRoleTag extends GetxService {
  String role = 'buyer';
}