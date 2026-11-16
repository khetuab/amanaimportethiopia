import 'package:get/get.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../routes/app_routes.dart';

class CompareQuotationsController extends GetxController {
  CompareQuotationsController(this._repo);
  final QuotationRepository _repo;

  late String requestId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<QuotationModel> quotations = <QuotationModel>[].obs;

  double? get _lowestPrice => quotations.isEmpty
      ? null
      : quotations.map((q) => q.totalPriceETB).reduce((a, b) => a < b ? a : b);

  bool isLowest(QuotationModel q) => q.totalPriceETB == _lowestPrice;

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
      final list = await _repo.forRequest(requestId);
      quotations.assignAll(list);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void openDetail(QuotationModel q) =>
      Get.toNamed(AppRoutes.quotationDetail, arguments: q)?.then((_) => load());
}
