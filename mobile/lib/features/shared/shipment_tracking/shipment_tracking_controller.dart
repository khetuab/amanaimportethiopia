import 'package:get/get.dart';

import '../../../core/utils/error_handler.dart';
import '../../../data/models/shipment_model.dart';
import '../../../data/repositories/shipment_repository.dart';

class ShipmentTrackingController extends GetxController {
  ShipmentTrackingController(this._repo);
  final ShipmentRepository _repo;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<ShipmentModel> shipment = Rxn<ShipmentModel>();

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? '';
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      shipment.value = await _repo.forOrder(orderId);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }
}
