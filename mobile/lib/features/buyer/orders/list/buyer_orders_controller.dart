import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../routes/app_routes.dart';

class BuyerOrdersController extends GetxController {
  BuyerOrdersController(this._repo);
  final OrderRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxString filter = 'all'.obs;

  static const _filters = [
    'all',
    'awaiting_payment_confirmation',
    'payment_condition_satisfied',
    'in_transit',
    'delivered',
    'completed',
    'disputed',
  ];
  List<String> get filters => _filters;

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
      orders.assignAll(res.items);
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
    AppRoutes.buyerOrderDetail,
    arguments: o.id,
  )?.then((_) => load());
}
