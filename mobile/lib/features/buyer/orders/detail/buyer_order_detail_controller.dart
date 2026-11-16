import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../requests/widgets/order_image.dart';

class BuyerOrderDetailController extends GetxController {
  BuyerOrderDetailController(this._repo);
  final OrderRepository _repo;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxList<String> imageUrls = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      order.value = await _repo.getById(orderId);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
    _loadImages(); // not awaited, so the page shows immediately
  }

  Future<void> _loadImages() async {
    final o = order.value;
    if (o == null) return;
    imageUrls.assignAll(await OrderImageService.to.urlsFor(o));
  }

  void goToPayment() => Get.toNamed(
    AppRoutes.paymentInstructions,
    arguments: orderId,
  )?.then((_) => load());

  void goToSubmitEvidence() => Get.toNamed(
    AppRoutes.submitPaymentEvidence,
    arguments: orderId,
  )?.then((_) => load());

  void goToDispute() => Get.toNamed(
    AppRoutes.createDispute,
    arguments: orderId,
  )?.then((_) => load());

  void goToReview() => Get.toNamed(
    AppRoutes.createReview,
    arguments: orderId,
  )?.then((_) => load());

  Future<void> confirmReceipt() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('buyer.orders.detail.confirmReceiptTitle'.tr),
        content: Text('buyer.orders.detail.confirmReceiptBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('common.confirm'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.transition(orderId, 'buyer_confirm_receipt');
      SnackbarHelper.success('buyer.orders.detail.orderCompleted'.tr);
      await load();
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }
}
