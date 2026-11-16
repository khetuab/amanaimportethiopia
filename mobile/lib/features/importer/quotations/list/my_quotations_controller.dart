import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../routes/app_routes.dart';

class MyQuotationsController extends GetxController {
  MyQuotationsController(this._repo);
  final QuotationRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<QuotationModel> items = <QuotationModel>[].obs;
  final RxString filter = 'all'.obs;

  static const filters = [
    'all',
    'submitted',
    'accepted',
    'rejected',
    'withdrawn',
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _repo.myQuotations(
        status: filter.value == 'all' ? null : filter.value,
      );
      items.assignAll(res.items);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> setFilter(String f) async {
    filter.value = f;
    await load();
  }

  void openEdit(QuotationModel q) =>
      Get.toNamed(AppRoutes.editQuotation, arguments: q)?.then((_) => load());
}
