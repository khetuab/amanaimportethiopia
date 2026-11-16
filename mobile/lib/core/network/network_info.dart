import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkInfo extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isOnline = true.obs;

  bool get isOnline => _isOnline.value;
  Stream<bool> get onlineStream => _isOnline.stream;

  @override
  void onInit() {
    super.onInit();
    _watch();
  }

  void _watch() {
    _connectivity.onConnectivityChanged.listen((results) {
      _isOnline.value = !results.contains(ConnectivityResult.none);
    });
    _connectivity.checkConnectivity().then((results) {
      _isOnline.value = !results.contains(ConnectivityResult.none);
    });
  }
}
