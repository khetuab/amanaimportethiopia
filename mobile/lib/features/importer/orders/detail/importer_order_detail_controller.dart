import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../buyer/requests/widgets/order_image.dart';

class ImporterOrderDetailController extends GetxController {
  ImporterOrderDetailController(this._repo);
  final OrderRepository _repo;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<OrderModel> order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
    load();
  }

  // Future<void> load() async {
  //   loading.value = true;
  //   error.value = null;
  //   try {
  //     order.value = await _repo.getById(orderId);
  //   } catch (e) {
  //     error.value = ErrorHandler.messageFor(e);
  //   } finally {
  //     loading.value = false;
  //   }
  // }

  final RxList<String> imageUrls = <String>[].obs;

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      order.value = await _repo.getById(orderId);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
    _loadImages(); // not awaited, so the page shows immediately
  }

  Future<void> _loadImages() async {
    final o = order.value;
    if (o == null) return;
    imageUrls.assignAll(await OrderImageService.to.urlsFor(o));
  }
  void updateStatus() => Get.toNamed(
    AppRoutes.updateOrderStatus,
    arguments: orderId,
  )?.then((_) => load());

  void viewShipment() => Get.toNamed(
    AppRoutes.shipmentTracking,
    arguments: orderId,
  )?.then((_) => load());
}
