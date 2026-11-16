import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/repositories/review_repository.dart';
import '../../../../routes/app_routes.dart';

class CreateReviewController extends GetxController {
  CreateReviewController(this._repo);
  final ReviewRepository _repo;

  late String orderId;

  final RxInt rating = 5.obs;
  final commentCtrl = TextEditingController();
  final RxInt communication = 5.obs;
  final RxInt delivery = 5.obs;
  final RxInt quality = 5.obs;
  final RxBool submitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
  }

  void setRating(int r) => rating.value = r;
  void setComm(int r) => communication.value = r;
  void setDel(int r) => delivery.value = r;
  void setQual(int r) => quality.value = r;

  Future<void> submit() async {
    if (submitting.value) return;
    submitting.value = true;
    try {
      await _repo.forOrder(orderId, {
        'rating': rating.value,
        'comment': commentCtrl.text.trim(),
        'communicationRating': communication.value,
        'deliveryRating': delivery.value,
        'qualityRating': quality.value,
      });
      SnackbarHelper.success('buyer.reviews.thanks'.tr);
      Get.offAllNamed(AppRoutes.buyerOrderDetail, arguments: orderId);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    super.onClose();
  }
}
