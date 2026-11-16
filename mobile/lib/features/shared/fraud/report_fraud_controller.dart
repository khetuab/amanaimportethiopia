import 'dart:io';

import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/image_compress_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/repositories/report_repository.dart';

class ReportFraudController extends GetxController {
  ReportFraudController(this._repo, this._dio);
  final ReportRepository _repo;
  final DioClient _dio;

  final formKey = GlobalKey<FormState>();
  final descriptionCtrl = TextEditingController();
  final RxString category = 'suspected_fraud'.obs;
  final RxList<XFile> images = <XFile>[].obs;
  final RxBool submitting = false.obs;
  String? orderId;

  static const categories = [
    'suspected_fraud',
    'fake_importer',
    'counterfeit_product',
    'payment_scam',
    'off_platform_deal',
    'harassment',
    'other',
  ];

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String?;
  }

  void setCategory(String c) => category.value = c;
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
      await _repo.submitFraudReport(
        category: category.value,
        description: descriptionCtrl.text.trim(),
        relatedOrderId: orderId,
        evidence: evidence,
      );
      SnackbarHelper.success('fraud.reportSubmitted'.tr);
      Get.back();
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  String? validateDescription(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 10) {
      return 'fraud.validation.minLength'.tr;
    }
    if (s.length > 3000) return 'fraud.validation.tooLong'.tr;
    return null;
  }

  String humanize(String s) => Formatters.humanize(s);

  @override
  void onClose() {
    descriptionCtrl.dispose();
    super.onClose();
  }
}
