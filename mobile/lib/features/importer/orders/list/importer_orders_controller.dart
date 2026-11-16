import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../routes/app_routes.dart';

class ImporterOrdersController extends GetxController {
  ImporterOrdersController(this._repo);
  final OrderRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<OrderModel> items = <OrderModel>[].obs;
  final RxString filter = 'all'.obs;

  static const filters = [
    'all',
    'awaiting_payment_confirmation',
    'processing',
    'in_transit',
    'delivered',
    'completed',
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
      final res = await _repo.list(
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

  void open(OrderModel o) => Get.toNamed(
    AppRoutes.importerOrderDetail,
    arguments: o.id,
  )?.then((_) => load());
}
