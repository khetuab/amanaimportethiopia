/// Route name constants. Route table lives in `lib/routes/app_pages.dart`
/// and is wired during Phase 3.2.
class Routes {
  Routes._();

  // Bootstrap
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Shared
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String conversations = '/messages';
  static const String chat = '/messages/chat';

  // Buyer
  static const String buyerHome = '/buyer/home';
  static const String myRequests = '/buyer/requests';
  static const String createRequest = '/buyer/requests/create';
  static const String requestDetail = '/buyer/requests/detail';
  static const String compareQuotations = '/buyer/quotations/compare';
  static const String quotationDetail = '/buyer/quotations/detail';
  static const String buyerOrders = '/buyer/orders';
  static const String buyerOrderDetail = '/buyer/orders/detail';
  static const String paymentInstructions = '/buyer/orders/payment';
  static const String submitPaymentEvidence = '/buyer/orders/payment/submit';
  static const String createDispute = '/buyer/disputes/create';
  static const String disputeDetail = '/buyer/disputes/detail';
  static const String createReview = '/buyer/reviews/create';

  // Importer
  static const String importerDashboard = '/importer/dashboard';
  static const String submitVerification = '/importer/verification/submit';
  static const String verificationStatus = '/importer/verification/status';
  static const String browseRequests = '/importer/requests/browse';
  static const String submitQuotation = '/importer/quotations/submit';
  static const String myQuotations = '/importer/quotations';
  static const String editQuotation = '/importer/quotations/edit';
  static const String importerOrders = '/importer/orders';
  static const String importerOrderDetail = '/importer/orders/detail';
  static const String updateOrderStatus = '/importer/orders/update';
  static const String businessProfile = '/importer/profile';
  static const String shipmentTracking = '/shipment-tracking';
}
