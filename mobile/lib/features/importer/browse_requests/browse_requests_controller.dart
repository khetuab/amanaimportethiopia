import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_request_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../routes/app_routes.dart';
import '../../buyer/requests/widgets/order_image.dart';

class BrowseRequestsController extends GetxController {
  BrowseRequestsController(this._auth, this._cats, this._reqs);
  final AuthService _auth;
  final CategoryRepository _cats;
  final RequestRepository _reqs;


  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<ProductRequestModel> items = <ProductRequestModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final RxString search = ''.obs;
  final RxString sort = 'newest'.obs;
  final RxString city = 'Addis Ababa'.obs;
  final RxnString categoryId = RxnString();

  final RxInt page = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _boot();
  }

  Future<void> _boot() async {
    loading.value = true;
    try {
      categories.assignAll(await _cats.list());
    } catch (_) {}
    await load(refresh: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) page.value = 1;
    loading.value = true;
    error.value = null;
    try {
      final res = await _reqs.browse(
        categoryId: categoryId.value,
        city: city.value,
        q: search.value.trim().isEmpty ? null : search.value.trim(),
        sort: sort.value,
        page: page.value,
      );
      OrderImageService.to.rememberAll(res.items);
      if (refresh || page.value == 1) {
        items.assignAll(res.items);
      } else {
        items.addAll(res.items);
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

  void setSearch(String v) => search.value = v;
  void setSort(String v) {
    sort.value = v;
    load(refresh: true);
  }

  void setCity(String v) {
    city.value = v;
    load(refresh: true);
  }

  void setCategory(String? id) {
    categoryId.value = id;
    load(refresh: true);
  }

  void openDetail(ProductRequestModel r) => Get.toNamed(
    AppRoutes.submitQuotation,
    arguments: r,
  )?.then((_) => load(refresh: true));

  bool get isApproved => _auth.user?.role == 'importer';
}
