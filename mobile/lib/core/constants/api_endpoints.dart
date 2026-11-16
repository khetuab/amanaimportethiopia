/// Backend endpoint paths. Never call Dio directly from controllers —
/// go through the repositories in `data/repositories/`.
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ---- Users ----
  static const String usersMe = '/users/me';
  static const String usersChangePassword = '/users/me/change-password';
  static const String usersFcmToken = '/users/me/fcm-token';

  // ---- Categories ----
  static const String categories = '/categories';
  static String category(String id) => '/categories/$id';

  // ---- Importers ----
  static const String importerMyProfile = '/importers/me';
  static const String importerSubmitVerification = '/importers/me/verification';
  static const String importerAddDocument = '/importers/me/documents';
  static String importerRemoveDocument(String id) =>
      '/importers/me/documents/$id';

  // ---- Requests ----
  static const String createRequest = '/requests';
  static const String myRequests = '/requests/me';
  static String request(String id) => '/requests/me/$id';
  static String requestPublish(String id) => '/requests/me/$id/publish';
  static String requestCancel(String id) => '/requests/me/$id/cancel';
  static const String browseRequests = '/requests/browse';
  static String browseRequestDetail(String id) => '/requests/browse/$id';

  // ---- Quotations ----
  static String quotationsForRequest(String requestId) =>
      '/quotations/requests/$requestId/quotes';
  static const String myQuotations = '/quotations/my-quotes';
  static String quotation(String id) => '/quotations/$id';
  static String quotationWithdraw(String id) => '/quotations/$id/withdraw';
  static String quotationAccept(String id) => '/quotations/$id/accept';

  // ---- Orders ----
  static const String orders = '/orders/me';
  static String order(String id) => '/orders/me/$id';
  static String orderTransition(String id) => '/orders/$id/transition';

  // ---- Payments ----
  static String paymentInstructions(String orderId) =>
      '/payments/orders/$orderId/instructions';
  static String paymentSubmit(String orderId) =>
      '/payments/orders/$orderId/submit';
  static String paymentMineForOrder(String orderId) =>
      '/payments/orders/$orderId/mine';

  // ---- Commissions (fee preview) ----
  static const String commissionPreview = '/commissions/preview';

  // ---- Notifications ----
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // ---- Shipments ----
  static String shipmentForOrder(String orderId) =>
      '/shipments/orders/$orderId';
  static String shipmentAddEvent(String orderId) =>
      '/shipments/orders/$orderId/events';

  // ---- Messages ----
  static const String conversations = '/messages';
  static String conversation(String id) => '/messages/$id';
  static String conversationMessages(String id) => '/messages/$id/messages';

  // ---- Disputes ----
  static const String myDisputes = '/disputes';
  static String disputesForOrder(String orderId) => '/disputes/orders/$orderId';
  static String disputeOpen(String orderId) => '/disputes/orders/$orderId';
  static String disputeMessage(String id) => '/disputes/$id/messages';
  static String disputeWithdraw(String id) => '/disputes/$id/withdraw';

  // ---- Reviews ----
  static String reviewsForImporter(String importerId) =>
      '/reviews/importers/$importerId';
  static String reviewOrder(String orderId) => '/reviews/orders/$orderId';

  // ---- Uploads ----
  static const String uploadSingle = '/uploads/single';
  static const String uploadMultiple = '/uploads/multiple';

  // ---- Fraud ----
  static const String fraudReports = '/fraud-reports';
}
