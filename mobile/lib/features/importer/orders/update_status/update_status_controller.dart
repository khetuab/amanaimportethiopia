import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/shipment_repository.dart';

/// Result of the last successful status change (drives the success banner).
class StatusChange {
  const StatusChange({required this.from, required this.to, required this.at});
  final String from;
  final String to;
  final DateTime at;
}

class UpdateStatusController extends GetxController {
  UpdateStatusController(this._orders, this._shipments);
  final OrderRepository _orders;
  final ShipmentRepository _shipments;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxString selectedAction = ''.obs;
  final noteCtrl = TextEditingController();
  final RxBool submitting = false.obs;

  /// Set after a successful update; the page shows a success banner.
  final Rxn<StatusChange> lastChange = Rxn<StatusChange>();

  /// Tracking updates posted during this visit (stage -> time).
  final RxMap<String, DateTime> postedStages = <String, DateTime>{}.obs;
  final RxnString postingStage = RxnString();

  // Map current order status -> next allowed actions
  static const _transitions = <String, List<String>>{
    'payment_condition_satisfied': ['importer_start_processing'],
    'processing': ['importer_mark_shipped', 'importer_cancel'],
    'import_shipment_in_progress': [
      'importer_mark_customs',
      'importer_mark_in_transit',
    ],
    'customs_clearance': ['importer_mark_in_transit'],
    'in_transit': ['importer_mark_ready'],
    'ready_for_delivery': ['importer_mark_delivered'],
  };

  List<String> get availableActions =>
      _transitions[order.value?.status] ?? const [];

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
    load();
  }

  /// [silent] reloads without showing the skeleton (used after saving).
  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    error.value = null;
    try {
      final o = await _orders.getById(orderId);
      order.value = o;
      final actions = _transitions[o.status] ?? const <String>[];
      selectedAction.value = actions.isEmpty ? '' : actions.first;
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void selectAction(String a) => selectedAction.value = a;

  Future<void> submit() async {
    if (submitting.value) return;
    if (selectedAction.value.isEmpty) {
      SnackbarHelper.warning('importer.orderUpdate.chooseAnAction'.tr);
      return;
    }
    submitting.value = true;
    try {
      final from = order.value?.status ?? '';
      await _orders.transition(
        orderId,
        selectedAction.value,
        note: noteCtrl.text.trim(),
      );
      noteCtrl.clear();
      await load(silent: true);
      lastChange.value = StatusChange(
        from: from,
        to: order.value?.status ?? '',
        at: DateTime.now(),
      );
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  /// Post a shipment event (importer -> buyer visible tracking).
  Future<void> postShipmentEvent({
    required String stage,
    required String description,
    String? location,
  }) async {
    if (postingStage.value != null) return;
    postingStage.value = stage;
    try {
      await _shipments.addEvent(orderId, {
      'stage': stage,
      'description': description,
      'location': ?location,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      });
      postedStages[stage] = DateTime.now();
      SnackbarHelper.success('importer.orderUpdate.trackingSent'.tr);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      postingStage.value = null;
    }
  }

  String humanize(String s) => Formatters.humanize(s);

  @override
  void onClose() {
    noteCtrl.dispose();
    super.onClose();
  }
}