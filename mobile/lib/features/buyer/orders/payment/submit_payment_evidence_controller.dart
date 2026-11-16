import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/cloudinary_config.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../requests/list/my_requests_controller.dart';
import '../list/buyer_orders_controller.dart';

class SubmitPaymentEvidenceController extends GetxController {
  SubmitPaymentEvidenceController(this._repo, this._cloudinary);
  final PaymentRepository _repo;
  final CloudinaryService _cloudinary;

  late String orderId;

  final formKey = GlobalKey<FormState>();
  final referenceCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final RxString channel = 'bank_transfer'.obs;
  final Rx<DateTime> paidAt = DateTime.now().obs;
  final RxList<XFile> receipts = <XFile>[].obs;
  final RxBool submitting = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
  }

  void pickChannel(String v) => channel.value = v;
  void pickPaidAt(DateTime d) => paidAt.value = d;

  void addReceipt(XFile f) => receipts.add(f);
  void removeReceipt(XFile f) => receipts.remove(f);

  Future<void> submit() async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    submitting.value = true;
    uploadProgress.value = 0;
    try {
      // 1) Upload the receipt to Cloudinary first.
      CloudinaryUpload? receipt;
      if (receipts.isNotEmpty) {
        receipt = await _cloudinary.uploadImage(
          receipts.first,
          folder: CloudinaryConfig.receiptFolder,
          uploadPreset: CloudinaryConfig.receiptPreset,
          onProgress: (p) => uploadProgress.value = p,
        );
      }

      // 2) Send the payment evidence to our backend.
      await _repo.submit(orderId, {
        'transactionReference': referenceCtrl.text.trim(),
        'amountETB': double.tryParse(amountCtrl.text.trim()) ?? 0,
        'paymentChannel': channel.value,
        'paidAt': paidAt.value.toUtc().toIso8601String(),
        if (receipt != null) ...{
          'receiptKey': receipt.publicId,
          'receiptUrl': receipt.url,
          'receiptMimeType': receipt.mimeType,
          'receiptProvider': 'cloudinary',
          'receiptDeliveryType': receipt.deliveryType,
        },
      });

      Get.until((route) => route.settings.name == '/buyer' || route.isFirst);

      if (Get.isRegistered<MyRequestsController>()) {
        Get.find<MyRequestsController>().load(refresh: true);
      }
      if (Get.isRegistered<BuyerOrdersController>()) {
        Get.find<BuyerOrdersController>().load();
      }

      SnackbarHelper.success('buyer.orders.payment.evidenceSubmitted'.tr);
    } on CloudinaryException catch (e) {
      SnackbarHelper.warning(e.message);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  String? validateReference(String? v) =>
      Validators.minLength(v, 4, field: 'buyer.orders.payment.referenceLabel'.tr);
  String? validateAmount(String? v) =>
      Validators.positiveNumber(v, field: 'buyer.orders.payment.amount'.tr);

  @override
  void onClose() {
    referenceCtrl.dispose();
    amountCtrl.dispose();
    super.onClose();
  }
}