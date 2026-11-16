
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/models/quotation_model.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../data/repositories/request_repository.dart';
import '../../../../routes/app_routes.dart';

class QuotationDetailController extends GetxController {
  QuotationDetailController(
      this._quotes,
      this._dio, {
        required this.requests,
      });

  final QuotationRepository _quotes;
  final DioClient _dio;
  final RequestRepository requests;


  late String quotationId;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<QuotationModel> quotation = Rxn<QuotationModel>();

  // Commission preview state.

  final RxBool feeLoading = false.obs;
  final RxnDouble feeETB = RxnDouble();
  final RxnDouble buyerTotal = RxnDouble();
  final RxnString feePayer = RxnString();

  // Prevent repeated submissions from this controller instance.
  final RxBool accepting = false.obs;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;

    if (arg is QuotationModel) {
      quotationId = arg.id;
    } else if (arg is String) {
      quotationId = arg;
    } else {
      quotationId = '';
    }

    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;

    try {
      final arg = Get.arguments;

      if (arg is QuotationModel) {
        quotation.value = arg;
        await _loadFeePreview(arg);
        return;
      }

      // The current API does not provide GET /quotations/:id.
      // A quotation ID alone cannot populate this screen.
      throw Exception(
        'Quotation details are unavailable. '
            'Please return to the quotations list and open the quotation again.',
      );
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadFeePreview(QuotationModel q) async {
    feeLoading.value = true;

    // Clear stale preview values before fetching a new one.
    feeETB.value = null;
    buyerTotal.value = null;
    feePayer.value = null;

    try {
      if (q.requestId.isEmpty) {
        debugPrint(
          '[COMMISSION PREVIEW] Missing request ID '
              'for quotation ${q.id}',
        );
        return;
      }

      // Fetch the request to obtain the real category ID.
      final request = await requests.getById(q.requestId);

      if (request.categoryId.isEmpty) {
        debugPrint(
          '[COMMISSION PREVIEW] Missing category ID '
              'for request ${q.requestId}',
        );
        return;
      }

      final response = await _dio.dio.get(
        ApiEndpoints.commissionPreview,
        queryParameters: {
          'categoryId': request.categoryId,
          'orderValueETB': q.totalPriceETB,
        },
      );

      final body = response.data;
      final data = body is Map ? body['data'] : null;

      if (data is Map) {
        double? parseAmount(dynamic value) {
          if (value is num) return value.toDouble();
          return double.tryParse(value?.toString() ?? '');
        }

        feeETB.value = parseAmount(data['feeETB']);
        buyerTotal.value = parseAmount(data['buyerTotalETB']);
        feePayer.value = data['payer']?.toString();

        debugPrint('[COMMISSION PREVIEW] Fee: ${feeETB.value}');
        debugPrint('[COMMISSION PREVIEW] Buyer total: ${buyerTotal.value}');
      }
    } catch (e, st) {
      // The preview is optional; the server still validates the
      // actual commission when the quotation is accepted.
      debugPrint('[COMMISSION PREVIEW] Failed: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      feeLoading.value = false;
    }
  }


  Future<void> accept() async {
    final q = quotation.value;

    if (q == null || accepting.value) return;

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('buyer.quotations.detail.acceptDialogTitle'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('buyer.quotations.detail.totalLine'
                .trParams({'amount': Formatters.etb(q.totalPriceETB)})),

            if (feeLoading.value)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('buyer.quotations.detail.calculatingFee'.tr),
              ),

            if (feeETB.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'buyer.quotations.detail.platformFeeLine'.trParams({
                    'amount': Formatters.etb(feeETB.value!),
                    'payer': feePayer.value ?? 'buyer',
                  }),
                ),
              ),

            if (buyerTotal.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'buyer.quotations.detail.buyerTotalLine'
                      .trParams({'amount': Formatters.etb(buyerTotal.value!)}),
                ),
              ),

            const SizedBox(height: 8),

            Text(
              'buyer.quotations.detail.acceptIrreversible'.tr,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('buyer.quotations.detail.accept'.tr),
          ),
        ],
      ),
    );

    if (ok != true || accepting.value) return;

    accepting.value = true;

    try {
      final orderMap = await _quotes.accept(q.id);

      final orderId =
      (orderMap['_id'] ?? orderMap['id'])?.toString();

      if (orderId == null || orderId.isEmpty) {
        throw Exception(
          'The quotation may have been accepted, '
              'but the server did not return an order ID. '
              'Check your orders before trying again.',
        );
      }

      Get.offNamedUntil(
        AppRoutes.buyerOrderDetail,
            (route) => route.settings.name == '/buyer',
        arguments: orderId,
      );

      SnackbarHelper.success('buyer.quotations.detail.acceptedToast'.tr);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      accepting.value = false;
    }
  }

}
