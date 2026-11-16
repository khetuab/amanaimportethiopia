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
import '../../../../data/models/importer_profile_model.dart';
import '../../../../data/repositories/importer_repository.dart';
import '../../../../routes/app_routes.dart';

class SubmitVerificationController extends GetxController {
  SubmitVerificationController(this._repo, this._dio);
  final ImporterRepository _repo;
  final DioClient _dio;

  final formKey = GlobalKey<FormState>();
  final businessNameCtrl = TextEditingController();
  final tinCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();

  final RxString businessType = 'company'.obs;
  final RxList<String> serviceAreas = <String>['Addis Ababa'].obs;
  final RxList<Map<String, dynamic>> documents = <Map<String, dynamic>>[].obs;
  final Rx<DateTime?> licenseExpiry = Rx<DateTime?>(null);

  final RxBool loading = true.obs;
  final RxBool submitting = false.obs;
  final Rxn<ImporterProfileModel> existing = Rxn<ImporterProfileModel>();

  /// True once the profile exists in the backend.
  /// Documents can only be uploaded/attached when this is true.
  bool get _profileExists => existing.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    loading.value = true;
    try {
      final res = await _repo.getMyProfile();
      existing.value = res.profile;
      _hydrate(res.profile);
      documents.assignAll(
        res.documents.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(),
      );
    } catch (_) {
      // No profile yet — this is expected on first submission.
    } finally {
      loading.value = false;
    }
  }

  void _hydrate(ImporterProfileModel p) {
    businessNameCtrl.text = p.businessName;
    tinCtrl.text = p.tinNumber ?? '';
    licenseCtrl.text = p.businessLicenseNumber ?? '';
    descriptionCtrl.text = p.description ?? '';
    yearCtrl.text = p.yearEstablished?.toString() ?? '';
    contactPhoneCtrl.text = p.contactPhone ?? '';
    contactEmailCtrl.text = p.contactEmail ?? '';
    businessType.value = p.businessType;
    serviceAreas.assignAll(p.serviceAreas.isEmpty ? ['Addis Ababa'] : p.serviceAreas);
  }

  void setBusinessType(String v) => businessType.value = v;

  void toggleServiceArea(String city) {
    if (serviceAreas.contains(city)) {
      serviceAreas.remove(city);
    } else {
      serviceAreas.add(city);
    }
  }

  void pickLicenseExpiry(DateTime? d) => licenseExpiry.value = d;

  /// Pick a document and — only if the profile already exists — upload it
  /// immediately to the backend. If the profile doesn't exist yet, the file
  /// is buffered in `pendingUploads` and uploaded after `submit()`.
  Future<void> pickDocument({
    required String type,
    required String label,
    bool allowPdf = true,
  }) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    if (!_profileExists) {
      // Buffer the file locally. It will be uploaded after submission.
      _pendingUploads.add((file: file, type: type, label: label));
      SnackbarHelper.info('importer.verification.docReady'
          .trParams({'doc': label}));
      return;
    }

    await _uploadAndAttach(file: file, type: type, label: label);
  }

  final List<({XFile file, String type, String label})> _pendingUploads = [];

  Future<void> _uploadAndAttach({
    required XFile file,
    required String type,
    required String label,
  }) async {
    submitting.value = true;
    try {
      final compressed = await ImageCompressService.compress(File(file.path));
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(compressed.path, filename: '$type.jpg'),
        'folder': 'verification',
      });
      final res = await _dio.dio.post(ApiEndpoints.uploadSingle, data: form);
      final data = (res.data is Map) ? (res.data['data'] as Map?) : null;
      if (data == null) throw Exception('Upload failed');

      final doc = await _repo.addDocument(
        type: type,
        fileKey: data['key'].toString(),
        fileUrl: data['url'].toString(),
        mimeType: data['mimeType'].toString(),
        size: (data['size'] as num).toInt(),
        label: label,
      );
      documents.add(doc);
      SnackbarHelper
          .success('importer.verification.docUploaded'.trParams({'doc': label}));
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  Future<void> removeDocument(String id) async {
    try {
      await _repo.removeDocument(id);
      documents.removeWhere((d) => d['_id'] == id);
      SnackbarHelper.success('importer.verification.docRemoved'.tr);
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  Future<void> submit() async {
    if (submitting.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    submitting.value = true;
    try {
      // 1) Create/update the profile first.
      await _repo.submitVerification({
        'businessName': businessNameCtrl.text.trim(),
        'businessType': businessType.value,
        if (tinCtrl.text.trim().isNotEmpty) 'tinNumber': tinCtrl.text.trim(),
        if (licenseCtrl.text.trim().isNotEmpty)
          'businessLicenseNumber': licenseCtrl.text.trim(),
        if (licenseExpiry.value != null)
          'licenseExpiryDate': licenseExpiry.value!.toUtc().toIso8601String(),
        if (descriptionCtrl.text.trim().isNotEmpty)
          'description': descriptionCtrl.text.trim(),
        if (yearCtrl.text.trim().isNotEmpty)
          'yearEstablished': int.tryParse(yearCtrl.text.trim()),
        if (contactPhoneCtrl.text.trim().isNotEmpty)
          'contactPhone': contactPhoneCtrl.text.trim(),
        if (contactEmailCtrl.text.trim().isNotEmpty)
          'contactEmail': contactEmailCtrl.text.trim(),
        'serviceAreas': serviceAreas.toList(),
      });

      // 2) Reload to get the created profile.
      final refreshed = await _repo.getMyProfile();
      existing.value = refreshed.profile;
      documents.assignAll(
        refreshed.documents.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList(),
      );

      // 3) Now upload any buffered documents.
      for (final pending in _pendingUploads) {
        await _uploadAndAttach(
          file: pending.file,
          type: pending.type,
          label: pending.label,
        );
      }
      _pendingUploads.clear();

      // 4) If the form requires at least one document and none was uploaded, warn.
      if (documents.isEmpty) {
        SnackbarHelper.warning(
          'importer.verification.profileSavedWarning'.tr,
        );
      } else {
        SnackbarHelper.success('importer.verification.submittedSuccess'.tr);
      }

      Get.offNamed(AppRoutes.verificationStatus);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      submitting.value = false;
    }
  }

  String? validateBusinessName(String? v) =>
      Validators.minLength(
          v, 2, field: 'importer.verification.businessName'.tr);
  String? validatePhone(String? v) {
    if ((v ?? '').trim().isEmpty) return null;
    return Validators.ethiopianPhone(v);
  }

  @override
  void onClose() {
    businessNameCtrl.dispose();
    tinCtrl.dispose();
    licenseCtrl.dispose();
    descriptionCtrl.dispose();
    yearCtrl.dispose();
    contactPhoneCtrl.dispose();
    contactEmailCtrl.dispose();
    super.onClose();
  }
}