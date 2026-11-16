import 'dart:io';

import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/image_compress_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/product_request_model.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../buyer/requests/widgets/order_image.dart';
import '../list/my_quotations_controller.dart';

class QuotationItemizedLine {
  QuotationItemizedLine({
    required this.label,
    required this.amountETB,
    this.note = '',
  });
  String label;
  double amountETB;
  String note;
}

class SubmitQuotationController extends GetxController {
  SubmitQuotationController(this._repo, this._dio);
  final QuotationRepository _repo;
  final DioClient _dio;

  late ProductRequestModel request;

  final formKey = GlobalKey<FormState>();
  final totalCtrl = TextEditingController();
  final deliveryDaysCtrl = TextEditingController(text: '14');
  final warrantyCtrl = TextEditingController();
  final returnCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final exclusionsCtrl = TextEditingController();
  final specsCtrl = TextEditingController();

  final RxString condition = 'new'.obs;
  final Rx<DateTime> validUntil = DateTime.now()
      .add(const Duration(days: 7))
      .obs;
  final RxBool estimateFinal = false.obs;
  final RxList<QuotationItemizedLine> lines = <QuotationItemizedLine>[].obs;
  final RxList<XFile> attachments = <XFile>[].obs;
  final RxBool submitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ProductRequestModel) {
      request = arg;
      OrderImageService.to.remember(arg);
    } else {
      Get.back();
    }
  }

  void setCondition(String v) => condition.value = v;
  void pickValidUntil(DateTime d) => validUntil.value = d;
  void setEstimateFinal(bool? v) => estimateFinal.value = v ?? false;

  void addLine() => lines.add(QuotationItemizedLine(label: '', amountETB: 0));

  void updateLine(int index, {String? label, double? amount, String? note}) {
    final l = lines[index];
    if (label != null) l.label = label;
    if (amount != null) l.amountETB = amount;
    if (note != null) l.note = note;
  }

  void removeLine(int index) => lines.removeAt(index);

  void addAttachment(XFile f) => attachments.add(f);
  void removeAttachment(XFile f) => attachments.remove(f);

  double get linesTotal => lines.fold(0, (s, l) => s + l.amountETB);

  Future<void> submit() async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    submitting.value = true;
    try {
      final attached = <Map<String, dynamic>>[];
      for (final a in attachments) {
        try {
          final file = await ImageCompressService.compress(File(a.path));
          final form = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              file.path,
              filename: 'quote.jpg',
            ),
            'folder': 'quotation-attachment',
          });
          final res = await _dio.dio.post(
            ApiEndpoints.uploadSingle,
            data: form,
          );
          final data = (res.data is Map) ? (res.data['data'] as Map?) : null;
          if (data != null) {
            attached.add({
              'key': data['key'],
              'url': data['url'],
              'mimeType': data['mimeType'],
              'size': data['size'],
              'originalName': data['originalName'] ?? 'quote.jpg',
            });
          }
        } catch (_) {}
      }

      await _repo.submit(request.id, {
        'totalPriceETB': double.tryParse(totalCtrl.text.trim()) ?? linesTotal,
        'itemizedCosts': lines
            .where((l) => l.label.trim().isNotEmpty && l.amountETB > 0)
            .map(
              (l) => {
                'label': l.label.trim(),
                'amountETB': l.amountETB,
                if (l.note.trim().isNotEmpty) 'note': l.note.trim(),
              },
            )
            .toList(),
        'isEstimateFinal': estimateFinal.value,
        if (exclusionsCtrl.text.trim().isNotEmpty)
          'exclusions': exclusionsCtrl.text.trim(),
        'productCondition': condition.value,
        if (specsCtrl.text.trim().isNotEmpty)
          'specifications': specsCtrl.text.trim(),
        if (warrantyCtrl.text.trim().isNotEmpty)
          'warrantyOffered': warrantyCtrl.text.trim(),
        if (returnCtrl.text.trim().isNotEmpty)
          'returnPolicy': returnCtrl.text.trim(),
        'estimatedDeliveryDays':
            int.tryParse(deliveryDaysCtrl.text.trim()) ?? 14,
        'quotationValidUntil': validUntil.value.toUtc().toIso8601String(),
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
        'attachments': attached,
      });

      if (Get.isRegistered<MyQuotationsController>()) {
        Get.find<MyQuotationsController>().load();
      }
      Get.back(); // pops the submit page; the shell and its nav bar are still underneath
      SnackbarHelper.success('importer.quotationSubmit.success'.tr);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  String? validateTotal(String? v) =>
      Validators.positiveNumber(
          v, field: 'importer.quotation.totalPriceField'.tr);
  String? validateDays(String? v) =>
      Validators.positiveNumber(
          v, field: 'importer.quotation.deliveryDays'.tr);

  @override
  void onClose() {
    totalCtrl.dispose();
    deliveryDaysCtrl.dispose();
    warrantyCtrl.dispose();
    returnCtrl.dispose();
    notesCtrl.dispose();
    exclusionsCtrl.dispose();
    specsCtrl.dispose();
    super.onClose();
  }
}
