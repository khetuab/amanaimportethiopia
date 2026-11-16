import 'dart:io';

import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/image_compress_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/repositories/dispute_repository.dart';
import '../../../../routes/app_routes.dart';

class CreateDisputeController extends GetxController {
  CreateDisputeController(this._repo, this._dio);
  final DisputeRepository _repo;
  final DioClient _dio;

  late String orderId;

  final formKey = GlobalKey<FormState>();
  final descriptionCtrl = TextEditingController();
  final RxString reason = 'non_delivery'.obs;
  final RxList<XFile> images = <XFile>[].obs;
  final RxBool submitting = false.obs;

  static const reasons = [
    'non_delivery',
    'damaged_goods',
    'incorrect_product',
    'spec_mismatch',
    'excessive_delay',
    'unapproved_charges',
    'cancellation',
    'payment_evidence',
    'other',
  ];

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
  }

  void pickReason(String r) => reason.value = r;

  void addImage(XFile f) => images.add(f);
  void removeImage(XFile f) => images.remove(f);

  Future<void> submit() async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    submitting.value = true;
    try {
      final evidence = <Map<String, dynamic>>[];
      for (final img in images) {
        try {
          final file = await ImageCompressService.compress(File(img.path));
          final form = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              file.path,
              filename: 'evidence.jpg',
            ),
            'folder': 'dispute-evidence',
          });
          final res = await _dio.dio.post(
            ApiEndpoints.uploadSingle,
            data: form,
          );
          final data = (res.data is Map) ? (res.data['data'] as Map?) : null;
          if (data != null) {
            evidence.add({
              'key': data['key'],
              'url': data['url'],
              'mimeType': data['mimeType'],
            });
          }
        } catch (_) {}
      }

      await _repo.open(orderId, {
        'reason': reason.value,
        'description': descriptionCtrl.text.trim(),
        'evidence': evidence,
      });

      SnackbarHelper.success('buyer.disputes.create.opened'.tr);
      Get.offAllNamed(AppRoutes.buyerOrderDetail, arguments: orderId);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  String? validateDescription(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 10)
      return 'buyer.disputes.create.descriptionTooShort'.tr;
    if (s.length > 3000) return 'buyer.disputes.create.descriptionTooLong'.tr;
    return null;
  }

  /// Display label for a dispute reason value (enum -> localized text).
  String humanReason(String r) => switch (r) {
    'non_delivery' => 'buyer.disputes.reason.nonDelivery'.tr,
    'damaged_goods' => 'buyer.disputes.reason.damagedGoods'.tr,
    'incorrect_product' => 'buyer.disputes.reason.incorrectProduct'.tr,
    'spec_mismatch' => 'buyer.disputes.reason.specMismatch'.tr,
    'excessive_delay' => 'buyer.disputes.reason.excessiveDelay'.tr,
    'unapproved_charges' => 'buyer.disputes.reason.unapprovedCharges'.tr,
    'cancellation' => 'buyer.disputes.reason.cancellation'.tr,
    'payment_evidence' => 'buyer.disputes.reason.paymentEvidence'.tr,
    'other' => 'buyer.disputes.reason.other'.tr,
    _ => Formatters.humanize(r),
  };

  @override
  void onClose() {
    descriptionCtrl.dispose();
    super.onClose();
  }
}
