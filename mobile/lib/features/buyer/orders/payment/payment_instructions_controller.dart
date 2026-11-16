import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../routes/app_routes.dart';

class PaymentInstructionsController extends GetxController {
  PaymentInstructionsController(this._repo);
  final PaymentRepository _repo;

  late String orderId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final RxMap<String, dynamic> instructions = <String, dynamic>{}.obs;

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
      final data = await _repo.getInstructions(orderId);
      final inst =
          (data['instructions'] as Map?)?.cast<String, dynamic>() ?? {};
      instructions.assignAll(inst);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void goToSubmit() => Get.toNamed(
    AppRoutes.submitPaymentEvidence,
    arguments: orderId,
  )?.then((_) => load());
}
