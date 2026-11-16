import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'auth_service.dart';
import 'local_notification_service.dart';

class NotificationsService extends GetxService with WidgetsBindingObserver {
  NotificationsService(this._repo, this._local);
  final NotificationRepository _repo;
  final LocalNotificationService _local;

  final RxList<NotificationModel> items = <NotificationModel>[].obs;
  final RxInt unread = 0.obs;

  final Set<String> _seen = {};
  bool _primed = false;
  bool _busy = false;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    refresh();
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  /// [throwOnError] lets the notifications page show its error state.
  Future<void> refresh({bool throwOnError = false}) async {
    final auth = Get.find<AuthService>();
    if (!auth.isAuthenticated) {
      // logged out: reset so the next user doesn't get old alerts
      items.clear();
      unread.value = 0;
      _seen.clear();
      _primed = false;
      return;
    }
    if (_busy) return;
    _busy = true;
    try {
      final res = await _repo.list();
      for (final n in res.items) {
        final id = n.id.toString();
        if (!n.isRead && !_seen.contains(id) && _primed) {
          _local.show(
            id: id.hashCode & 0x7fffffff,
            title: n.title,
            body: n.body,
          );
        }
        _seen.add(id);
      }
      _primed = true; // first fetch is silent: no spam for old unread items
      items.assignAll(res.items);
      unread.value = res.unreadCount;
    } catch (e) {
      if (throwOnError) rethrow;
    } finally {
      _busy = false;
    }
  }
}