import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Lightweight wrapper around connectivity_plus exposing an RxBool.
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool online = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((results) {
      online.value = !results.contains(ConnectivityResult.none);
    });
    _connectivity.checkConnectivity().then((results) {
      online.value = !results.contains(ConnectivityResult.none);
    });
  }
}
