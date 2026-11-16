import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_request_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/request_repository.dart';
import '../../../core/utils/error_handler.dart';

class BuyerHomeController extends GetxController {
  BuyerHomeController(this._auth, this._cats, this._requests);

  final AuthService _auth;
  final CategoryRepository _cats;
  final RequestRepository _requests;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductRequestModel> recentRequests =
      <ProductRequestModel>[].obs;

  String get userName =>
      _auth.user?.fullName.split(' ').first ?? 'buyer.home.nameFallback'.tr;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final cats = await _cats.list();
      categories.assignAll(cats.take(8));
      try {
        final res = await _requests.listMine(limit: 5);
        recentRequests.assignAll(res.items);
      } catch (_) {
        // Non-fatal — home still loads.
      }
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed('/auth/login');
  }
}
