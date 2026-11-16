import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/product_request_model.dart';
import '../../../../data/repositories/request_repository.dart';
import 'request_image.dart';

class OrderImageService {
  OrderImageService._(this._requests, this._auth);
  final RequestRepository _requests;
  final AuthService _auth;

  final Map<String, List<String>> _known = {}; // seen via browse / submit
  final Map<String, Future<List<String>>> _cache = {};

  static OrderImageService get to {
    if (Get.isRegistered<OrderImageService>()) {
      return Get.find<OrderImageService>();
    }
    return Get.put(
      OrderImageService._(
        RequestRepository(Get.find<DioClient>()),
        Get.find<AuthService>(),
      ),
      permanent: true,
    );
  }

  /// Call with requests the user has already loaded (browse list, submit page).
  void remember(ProductRequestModel r) {
    final urls = r.imageUrls;
    if (urls.isNotEmpty) _known[r.id] = urls;
  }

  void rememberAll(Iterable<ProductRequestModel> rs) => rs.forEach(remember);

  Future<List<String>> urlsForRequestId(String requestId) {
    if (requestId.isEmpty) return Future.value(const <String>[]);

    final known = _known[requestId];
    if (known != null) return Future.value(known);

    // Importers get 403 on /requests/me/:id, so don't even try.
    if (_auth.user?.role == 'importer') {
      return Future.value(const <String>[]);
    }

    return _cache.putIfAbsent(requestId, () async {
      try {
        final r = await _requests.getById(requestId);
        return r.imageUrls;
      } catch (_) {
        _cache.remove(requestId);
        return const <String>[];
      }
    });
  }

  Future<List<String>> urlsFor(OrderModel o) {
    final direct = o.snapshot.imageUrl;
    if (direct != null && direct.startsWith('http')) {
      return Future.value([direct]);
    }
    return urlsForRequestId(o.requestId);
  }
}

class OrderThumb extends StatelessWidget {
  const OrderThumb({
    super.key,
    required this.order,
    required this.icon,
    this.size = 56,
  });
  final OrderModel order;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: OrderImageService.to.urlsFor(order),
      builder: (_, snap) {
        final urls = snap.data;
        return ProductThumb(
          url: (urls == null || urls.isEmpty) ? null : urls.first,
          icon: icon,
          size: size,
        );
      },
    );
  }
}

class RequestIdThumb extends StatelessWidget {
  const RequestIdThumb({
    super.key,
    required this.requestId,
    required this.icon,
    this.size = 48,
  });
  final String requestId;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: OrderImageService.to.urlsForRequestId(requestId),
      builder: (_, snap) {
        final urls = snap.data;
        return ProductThumb(
          url: (urls == null || urls.isEmpty) ? null : urls.first,
          icon: icon,
          size: size,
        );
      },
    );
  }
}