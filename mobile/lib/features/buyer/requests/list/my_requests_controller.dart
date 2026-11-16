import 'package:get/get.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/product_request_model.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../routes/app_routes.dart';

class MyRequestsController extends GetxController {
  MyRequestsController(this._repo);
  final RequestRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<ProductRequestModel> requests = <ProductRequestModel>[].obs;
  final RxString filter = 'all'.obs;
  final RxInt page = 1.obs;
  final RxInt totalPages = 1.obs;

  static const _filters = [
    'all',
    'draft',
    'published',
    'receiving_offers',
    'offer_selected',
    'fulfilled',
  ];

  List<String> get filters => _filters;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      page.value = 1;
    }
    loading.value = true;
    error.value = null;
    try {
      final res = await _repo.listMine(
        status: filter.value == 'all' ? null : filter.value,
        page: page.value,
      );
      if (refresh || page.value == 1) {
        requests.assignAll(res.items);
      } else {
        requests.addAll(res.items);
      }
      totalPages.value = res.totalPages;
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  @override
  Future<void> refresh() => load(refresh: true);

  Future<void> setFilter(String f) async {
    filter.value = f;
    await load(refresh: true);
  }

  Future<void> loadMore() async {
    if (loading.value || page.value >= totalPages.value) return;
    page.value++;
    await load();
  }

  void goToCreate() => Get.toNamed(AppRoutes.createRequest);
  void openDetail(ProductRequestModel r) =>
      Get.toNamed(AppRoutes.requestDetail, arguments: r.id);
}
