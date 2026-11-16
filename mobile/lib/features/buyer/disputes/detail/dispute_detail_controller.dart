import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/dispute_model.dart';
import '../../../../data/repositories/dispute_repository.dart';

class DisputeDetailController extends GetxController {
  DisputeDetailController(this._repo);
  final DisputeRepository _repo;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxList<DisputeModel> disputes = <DisputeModel>[].obs;

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
      disputes.assignAll(await _repo.forOrder(orderId));
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }
}
