import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../data/models/message_model.dart';
import '../../../../data/repositories/message_repository.dart';

class ChatController extends GetxController {
  ChatController(this._repo, this._auth);
  final MessageRepository _repo;
  final AuthService _auth;

  late ConversationModel conversation;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final bodyCtrl = TextEditingController();
  final RxBool sending = false.obs;
  final ScrollController scrollCtrl = ScrollController();

  Timer? _poll;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ConversationModel) {
      conversation = arg;
      load();
      _poll = Timer.periodic(
        const Duration(seconds: 6),
        (_) => load(silent: true),
      );
    } else {
      Get.back();
    }
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    error.value = null;
    try {
      final list = await _repo.messages(conversation.id);
      final hadNew = list.length != messages.length;
      messages.assignAll(list);
      if (hadNew && !silent) _scrollToBottom();
    } catch (e) {
      if (!silent) error.value = ErrorHandler.messageFor(e);
    } finally {
      if (!silent) loading.value = false;
    }
  }

  Future<void> send() async {
    final body = bodyCtrl.text.trim();
    if (body.isEmpty || sending.value) return;
    sending.value = true;
    try {
      final msg = await _repo.send(conversation.id, body);
      messages.add(msg);
      bodyCtrl.clear();
      _scrollToBottom();
    } catch (e) {
      SnackbarHelper.error(ErrorHandler.messageFor(e));
    } finally {
      sending.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String get myUserId => _auth.user?.id ?? '';

  @override
  void onClose() {
    _poll?.cancel();
    bodyCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
