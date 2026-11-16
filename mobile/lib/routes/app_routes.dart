/// Central route-name constants. Screens import from here only.
/// `Routes` (core/config) mirrors these — do not diverge.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String splashes = '/splashes';

  // First-run language gate — shown once, before onboarding.
  static const String language = '/language';

  static const String onboarding = '/onboarding';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  static const String buyerShell = '/buyer';
  static const String importerShell = '/importer';

  // Buyer tab pages
  static const String buyerHome = '/buyer/home';
  static const String myRequests = '/buyer/requests';
  static const String buyerOrders = '/buyer/orders';
  static const String buyerProfile = '/buyer/profile';

  // Importer tab pages
  static const String importerDashboard = '/importer/dashboard';
  static const String browseRequests = '/importer/requests/browse';
  static const String importerOrders = '/importer/orders';
  static const String importerProfile = '/importer/profile';

  // Shared
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String conversations = '/messages';
  static const String chat = '/messages/chat';

  // Buyer — full flow (Phase 3.3)
  static const String requestDetail = '/buyer/requests/detail';
  static const String createRequest = '/buyer/requests/create';
  static const String compareQuotations = '/buyer/quotations/compare';
  static const String quotationDetail = '/buyer/quotations/detail';
  static const String buyerOrderDetail = '/buyer/orders/detail';
  static const String paymentInstructions = '/buyer/orders/payment';
  static const String submitPaymentEvidence = '/buyer/orders/payment/submit';
  static const String createDispute = '/buyer/disputes/create';
  static const String disputeDetail = '/buyer/disputes/detail';
  static const String createReview = '/buyer/reviews/create';

  // Importer — full flow (Phase 3.4)
  static const String submitVerification = '/importer/verification/submit';
  static const String verificationStatus = '/importer/verification/status';
  static const String submitQuotation = '/importer/quotations/submit';
  static const String myQuotations = '/importer/quotations';
  static const String editQuotation = '/importer/quotations/edit';
  static const String importerOrderDetail = '/importer/orders/detail';
  static const String updateOrderStatus = '/importer/orders/update';
  static const String businessProfile = '/importer/profile';
  static const String shipmentTracking = '/importer/shipments';

  static const String profile = '/profile';
  // static const String settings = '/settings';
  // static const String notifications = '/notifications';
  // static const String conversations = '/messages';
  // static const String chat = '/messages/chat';
  static const String reportFraud = '/report-fraud';
}
