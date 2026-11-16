import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/models/product_request_model.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../routes/app_routes.dart';

class RequestDetailController extends GetxController {
  RequestDetailController(this._repo);
  final RequestRepository _repo;

  late String requestId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<ProductRequestModel> request = Rxn<ProductRequestModel>();

  @override
  void onInit() {
    super.onInit();
    requestId = (Get.arguments as String?) ?? '';
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      request.value = await _repo.getById(requestId);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> publish() async {
    try {
      await _repo.publish(requestId);
      SnackbarHelper.success('buyer.requests.detail.publishedToast'.tr);
      await load();
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  Future<void> cancel() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('buyer.requests.detail.cancelDialogTitle'.tr),
        content: Text(
          'buyer.requests.detail.cancelDialogBody'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.back'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('buyer.requests.detail.cancelRequest'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.cancel(requestId);
      SnackbarHelper.success('buyer.requests.detail.cancelledToast'.tr);
      await load();
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  void viewQuotations() => Get.toNamed(
    AppRoutes.compareQuotations,
    arguments: requestId,
  )?.then((_) => load());
}
