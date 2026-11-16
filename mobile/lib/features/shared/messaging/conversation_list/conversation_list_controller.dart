import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/repositories/message_repository.dart';
import '../../../../routes/app_routes.dart';

class ConversationListController extends GetxController {
  ConversationListController(this._repo);
  final MessageRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<ConversationModel> items = <ConversationModel>[].obs;

  Timer? _poll;
  bool _started = false;

  @override
  void onInit() {
    super.onInit();
    _startAfterAuthReady();
  }

  Future<void> _startAfterAuthReady() async {
    final auth = Get.find<AuthService>();

    // Wait up to 3s for the session to be restored (splash restores it
    // before the shell renders, so this normally resolves in 1 tick).
    for (var i = 0; i < 30 && !auth.isAuthenticated; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (!auth.isAuthenticated) {
      loading.value = false;
      return;
    }
    if (_started) return;
    _started = true;

    await load();
    _poll = Timer.periodic(
      const Duration(seconds: 20),
          (_) => load(silent: true),
    );
  }

  Future<void> load({bool silent = false}) async {
    // Guard: silent polls never fire if the user is not authenticated.
    // Without this, a logged-out state (e.g. after a forced logout) would
    // keep 401-ing every 20 s.
    if (!Get.find<AuthService>().isAuthenticated) return;

    if (!silent) loading.value = true;
    error.value = null;
    try {
      items.assignAll(await _repo.conversations());
    } catch (e) {
      if (!silent) error.value = ErrorHandler.messageFor(e);
    } finally {
      if (!silent) loading.value = false;
    }
  }

  void openChat(ConversationModel c) =>
      Get.toNamed(AppRoutes.chat, arguments: c)?.then((_) => load());

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}