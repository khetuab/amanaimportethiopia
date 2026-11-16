import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/cloudinary_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/image_compress_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_request_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../home/buyer_home_controller.dart';

class CreateRequestController extends GetxController {
  CreateRequestController(this._cats, this._reqs, this._cloudinary);

  final CategoryRepository _cats;
  final RequestRepository _reqs;
  final CloudinaryService _cloudinary;

  final RxDouble uploadProgress = 0.0.obs;

  final formKey = GlobalKey<FormState>();

  // Core fields
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final referenceUrlCtrl = TextEditingController();
  final specificationsCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');
  final unitCtrl = TextEditingController(text: 'piece');
  final budgetMinCtrl = TextEditingController();
  final budgetMaxCtrl = TextEditingController();
  final deliveryCityCtrl = TextEditingController(text: 'Addis Ababa');
  final deliveryAddressCtrl = TextEditingController();
  final warrantyDetailsCtrl = TextEditingController();
  final qualityCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();

  // Selections
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<DateTime?> requiredDeliveryDate = Rx<DateTime?>(null);
  final Rx<DateTime> expiresAt = DateTime.now()
      .add(const Duration(days: 30))
      .obs;
  final RxBool warrantyRequired = false.obs;
  final RxList<XFile> images = <XFile>[].obs;

  // State
  final RxBool loadingCats = true.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxnString categoriesError = RxnString();
  final RxBool submitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    loadingCats.value = true;
    categoriesError.value = null;
    try {
      final list = await _cats.list();
      categories.assignAll(list);
    } catch (e) {
      categoriesError.value = ErrorHandler.messageFor(e);
    } finally {
      loadingCats.value = false;
    }
  }

  void pickCategory(CategoryModel? c) => selectedCategory.value = c;

  void pickDeliveryDate(DateTime? d) => requiredDeliveryDate.value = d;

  void pickExpiry(DateTime? d) => expiresAt.value = d ?? expiresAt.value;

  void toggleWarranty(bool? v) => warrantyRequired.value = v ?? false;

  void addImage(XFile file) => images.add(file);

  void removeImage(XFile file) => images.remove(file);


  final List<Map<String, dynamic>> _attachmentBuffer = [];

  Future<void> save({required bool publish}) async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selectedCategory.value == null) {
      SnackbarHelper.warning('buyer.requests.create.pleaseChooseCategory'.tr);
      return;
    }
    if (expiresAt.value.isBefore(DateTime.now())) {
      SnackbarHelper.warning('buyer.requests.create.expiryFuture'.tr);
      return;
    }

    submitting.value = true;
    uploadProgress.value = 0;
    try {
      // 1) Upload images FIRST, so a failed upload never leaves a half-made request.
      final attachments = images.isEmpty
          ? <Map<String, dynamic>>[]
          : (await _cloudinary.uploadImages(
        images.toList(),
        folder: CloudinaryConfig.requestFolder,
        onProgress: (p) => uploadProgress.value = p,
      ))
          .map((u) => u.toAttachment())
          .toList();

      // 2) Create the request WITH the attachments.
      final payload = <String, dynamic>{
        'title': titleCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'category': selectedCategory.value!.id,
        if (brandCtrl.text.trim().isNotEmpty) 'brand': brandCtrl.text.trim(),
        if (modelCtrl.text.trim().isNotEmpty) 'model': modelCtrl.text.trim(),
        if (referenceUrlCtrl.text.trim().isNotEmpty)
          'referenceUrl': referenceUrlCtrl.text.trim(),
        if (specificationsCtrl.text.trim().isNotEmpty)
          'specifications': specificationsCtrl.text.trim(),
        'quantity': int.tryParse(quantityCtrl.text.trim()) ?? 1,
        if (unitCtrl.text.trim().isNotEmpty)
          'unitOfMeasurement': unitCtrl.text.trim(),
        if (budgetMinCtrl.text.trim().isNotEmpty)
          'budgetMinETB': double.tryParse(budgetMinCtrl.text.trim()),
        if (budgetMaxCtrl.text.trim().isNotEmpty)
          'budgetMaxETB': double.tryParse(budgetMaxCtrl.text.trim()),
        'deliveryCity': deliveryCityCtrl.text.trim(),
        if (deliveryAddressCtrl.text.trim().isNotEmpty)
          'deliveryAddress': deliveryAddressCtrl.text.trim(),
        if (requiredDeliveryDate.value != null)
          'requiredDeliveryDate':
          requiredDeliveryDate.value!.toUtc().toIso8601String(),
        'warrantyRequired': warrantyRequired.value,
        if (warrantyDetailsCtrl.text.trim().isNotEmpty)
          'warrantyDetails': warrantyDetailsCtrl.text.trim(),
        if (qualityCtrl.text.trim().isNotEmpty)
          'qualityRequirements': qualityCtrl.text.trim(),
        if (instructionsCtrl.text.trim().isNotEmpty)
          'additionalInstructions': instructionsCtrl.text.trim(),
        'expiresAt': expiresAt.value.toUtc().toIso8601String(),
        if (attachments.isNotEmpty) 'attachments': attachments,
      };

      final created = await _reqs.create(payload);
      if (publish) await _reqs.publish(created.id);

      if (Get.isRegistered<BuyerHomeController>()) {
        Get.find<BuyerHomeController>().load();
      }

      Get.back(closeOverlays: true);
      SnackbarHelper.success(
        publish
            ? 'buyer.requests.create.publishedSuccess'.tr
            : 'buyer.requests.create.draftSaved'.tr,
      );
    } on CloudinaryException catch (e) {
      SnackbarHelper.warning(e.message);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }


  String? validateTitle(String? v) =>
      Validators.minLength(v, 4, field: 'buyer.requests.create.titleLabel'.tr);
  String? validateDescription(String? v) =>
      Validators.minLength(v, 10, field: 'buyer.requests.field.description'.tr);
  String? validateQuantity(String? v) =>
      Validators.positiveNumber(v, field: 'buyer.requests.field.quantity'.tr);
  String? validateCity(String? v) =>
      Validators.required(v, field: 'buyer.requests.field.deliveryCity'.tr);
  String? validateUrl(String? v) => Validators.url(v);

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    referenceUrlCtrl.dispose();
    specificationsCtrl.dispose();
    quantityCtrl.dispose();
    unitCtrl.dispose();
    budgetMinCtrl.dispose();
    budgetMaxCtrl.dispose();
    deliveryCityCtrl.dispose();
    deliveryAddressCtrl.dispose();
    warrantyDetailsCtrl.dispose();
    qualityCtrl.dispose();
    instructionsCtrl.dispose();
    super.onClose();
  }
}
