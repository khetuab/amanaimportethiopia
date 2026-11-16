import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../buyer/requests/widgets/order_image.dart';

class EditQuotationController extends GetxController {
  EditQuotationController(this._repo);
  final QuotationRepository _repo;

  late QuotationModel original;

  final formKey = GlobalKey<FormState>();
  final totalCtrl = TextEditingController();
  final deliveryDaysCtrl = TextEditingController();
  final warrantyCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final RxString condition = 'new'.obs;
  final Rx<DateTime> validUntil = DateTime.now()
      .add(const Duration(days: 7))
      .obs;
  final RxBool submitting = false.obs;
  final RxList<String> imageUrls = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is QuotationModel) {
      original = arg;
      totalCtrl.text = arg.totalPriceETB.toStringAsFixed(0);
      deliveryDaysCtrl.text = arg.estimatedDeliveryDays.toString();
      warrantyCtrl.text = arg.warrantyOffered ?? '';
      notesCtrl.text = arg.notes ?? '';
      condition.value = arg.productCondition;
      if (arg.quotationValidUntil != null) {
        validUntil.value = arg.quotationValidUntil!;
      }
    } else {
      Get.back();
    }
    _loadImages();
  }

  void setCondition(String v) => condition.value = v;
  void pickValidUntil(DateTime d) => validUntil.value = d;

  Future<void> _loadImages() async {
    imageUrls.assignAll(
      await OrderImageService.to.urlsForRequestId(original.requestId),
    );
  }
  Future<void> save() async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    submitting.value = true;
    try {
      await _repo.update(original.id, {
        'totalPriceETB':
            double.tryParse(totalCtrl.text.trim()) ?? original.totalPriceETB,
        'estimatedDeliveryDays':
            int.tryParse(deliveryDaysCtrl.text.trim()) ??
            original.estimatedDeliveryDays,
        'productCondition': condition.value,
        if (warrantyCtrl.text.trim().isNotEmpty)
          'warrantyOffered': warrantyCtrl.text.trim(),
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
        'quotationValidUntil': validUntil.value.toUtc().toIso8601String(),
      });
      SnackbarHelper.success('importer.quotationEdit.updated'.tr);
      Get.offAllNamed(AppRoutes.myQuotations);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  Future<void> withdraw() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('importer.quotationEdit.withdrawConfirmTitle'.tr),
        content: Text('importer.quotationEdit.withdrawConfirmBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('importer.quotationEdit.withdraw'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.withdraw(original.id);
      SnackbarHelper.success('importer.quotationEdit.withdrawn'.tr);
      Get.offAllNamed(AppRoutes.myQuotations);
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  String? validateTotal(String? v) =>
      Validators.positiveNumber(
          v, field: 'importer.quotation.totalPriceField'.tr);
  String? validateDays(String? v) =>
      Validators.positiveNumber(v, field: 'importer.quotation.fields.days'.tr);

  @override
  void onClose() {
    totalCtrl.dispose();
    deliveryDaysCtrl.dispose();
    warrantyCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
