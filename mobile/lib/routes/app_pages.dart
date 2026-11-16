import 'package:get/get.dart';
import '../core/routes/auth_transition.dart';
import '../features/auth/welcome/welcome_page.dart';
import '../features/shared/profile/profile_binding.dart';
import '../features/shared/profile/profile_page.dart';
import '../features/shared/settings/settings_binding.dart';
import '../features/shared/settings/settings_page.dart';
import '../features/shared/notifications/notifications_binding.dart';
import '../features/shared/notifications/notifications_page.dart';
import '../features/shared/messaging/conversation_list/conversation_list_binding.dart';
import '../features/shared/messaging/conversation_list/conversation_list_page.dart';
import '../features/shared/messaging/chat/chat_binding.dart';
import '../features/shared/messaging/chat/chat_page.dart';
import '../features/shared/fraud/report_fraud_binding.dart';
import '../features/shared/fraud/report_fraud_page.dart';
import '../features/auth/forgot_password/forgot_password_binding.dart';
import '../features/auth/forgot_password/forgot_password_page.dart';
import '../features/auth/login/login_binding.dart';
import '../features/auth/login/login_page.dart';
import '../features/auth/register/register_binding.dart';
import '../features/auth/register/register_page.dart';
import '../features/buyer/disputes/create/create_dispute_binding.dart';
import '../features/buyer/disputes/create/create_dispute_page.dart';
import '../features/buyer/disputes/detail/dispute_detail_binding.dart';
import '../features/buyer/disputes/detail/dispute_detail_page.dart';
import '../features/buyer/home/buyer_home_binding.dart';
import '../features/buyer/home/buyer_home_page.dart';
import '../features/buyer/orders/detail/buyer_order_detail_binding.dart';
import '../features/buyer/orders/detail/buyer_order_detail_page.dart';
import '../features/buyer/orders/list/buyer_orders_binding.dart';
import '../features/buyer/orders/list/buyer_orders_page.dart';
import '../features/buyer/orders/payment/payment_instructions_binding.dart';
import '../features/buyer/orders/payment/payment_instructions_page.dart';
import '../features/buyer/orders/payment/submit_payment_evidence_binding.dart';
import '../features/buyer/orders/payment/submit_payment_evidence_page.dart';
import '../features/buyer/quotations/compare/compare_quotations_binding.dart';
import '../features/buyer/quotations/compare/compare_quotations_page.dart';
import '../features/buyer/quotations/detail/quotation_detail_binding.dart';
import '../features/buyer/quotations/detail/quotation_detail_page.dart';
import '../features/buyer/requests/create/create_request_binding.dart';
import '../features/buyer/requests/create/create_request_page.dart';
import '../features/buyer/requests/detail/request_detail_binding.dart';
import '../features/buyer/requests/detail/request_detail_page.dart';
import '../features/buyer/requests/list/my_requests_binding.dart';
import '../features/buyer/requests/list/my_requests_page.dart';
import '../features/buyer/reviews/create_review_binding.dart';
import '../features/buyer/reviews/create_review_page.dart';
import '../features/importer/dashboard/importer_dashboard_binding.dart';
import '../features/importer/dashboard/importer_dashboard_page.dart';
import '../features/language/language_binding.dart';
import '../features/language/language_page.dart';
import '../features/navigation/main_shell.dart';
import '../features/onboarding/onboarding_binding.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/splash/splash_binding.dart';
import '../features/splash/splash_page.dart';
import 'app_routes.dart';

import '../features/importer/verification/submit/submit_verification_binding.dart';
import '../features/importer/verification/submit/submit_verification_page.dart';
import '../features/importer/verification/status/verification_status_binding.dart';
import '../features/importer/verification/status/verification_status_page.dart';
import '../features/importer/browse_requests/browse_requests_binding.dart';
import '../features/importer/browse_requests/browse_requests_page.dart';
import '../features/importer/quotations/submit/submit_quotation_binding.dart';
import '../features/importer/quotations/submit/submit_quotation_page.dart';
import '../features/importer/quotations/list/my_quotations_binding.dart';
import '../features/importer/quotations/list/my_quotations_page.dart';
import '../features/importer/quotations/edit/edit_quotation_binding.dart';
import '../features/importer/quotations/edit/edit_quotation_page.dart';
import '../features/importer/orders/list/importer_orders_binding.dart';
import '../features/importer/orders/list/importer_orders_page.dart';
import '../features/importer/orders/detail/importer_order_detail_binding.dart';
import '../features/importer/orders/detail/importer_order_detail_page.dart';
import '../features/importer/orders/update_status/update_status_binding.dart';
import '../features/importer/orders/update_status/update_status_page.dart';
import '../features/importer/business_profile/business_profile_binding.dart';
import '../features/importer/business_profile/business_profile_page.dart';
import '../features/shared/shipment_tracking/shipment_tracking_binding.dart';
import '../features/shared/shipment_tracking/shipment_tracking_page.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguagePage(),
      binding: LanguageBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.forgotPassword,
    //   page: () => const ForgotPasswordPage(),
    //   binding: ForgotPasswordBinding(),
    // ),

    GetPage(
      name: AppRoutes.buyerShell,
      page: () => const MainShell(role: MainShellRole.buyer),
      binding: BuyerHomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.importerShell,
      page: () => const MainShell(role: MainShellRole.importer),
      binding: ImporterDashboardBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.buyerHome,
      page: () => const BuyerHomePage(),
      binding: BuyerHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.importerDashboard,
      page: () => const ImporterDashboardPage(),
      binding: ImporterDashboardBinding(),
    ),

    // ---- Buyer request lifecycle ----
    GetPage(
      name: AppRoutes.createRequest,
      page: () => const CreateRequestPage(),
      binding: CreateRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.myRequests,
      page: () => const MyRequestsPage(),
      binding: MyRequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.requestDetail,
      page: () => const RequestDetailPage(),
      binding: RequestDetailBinding(),
    ),

    // ---- Buyer quotations ----
    GetPage(
      name: AppRoutes.compareQuotations,
      page: () => const CompareQuotationsPage(),
      binding: CompareQuotationsBinding(),
    ),
    GetPage(
      name: AppRoutes.quotationDetail,
      page: () => const QuotationDetailPage(),
      binding: QuotationDetailBinding(),
    ),

    // ---- Buyer orders ----
    GetPage(
      name: AppRoutes.buyerOrders,
      page: () => const BuyerOrdersPage(),
      binding: BuyerOrdersBinding(),
    ),
    GetPage(
      name: '/welcome',
      page: () => const WelcomePage(),
      customTransition: AuthTransition(),
      transitionDuration: const Duration(milliseconds: 450),
    ),
    GetPage(
      name: AppRoutes.forgotPassword, // must equal what the controller navigates to
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(), // must register ForgotPasswordController
      customTransition: AuthTransition(),
      transitionDuration: const Duration(milliseconds: 450),
    ),
// add the same customTransition + transitionDuration to /login and /register
    GetPage(
      name: AppRoutes.buyerOrderDetail,
      page: () => const BuyerOrderDetailPage(),
      binding: BuyerOrderDetailBinding(),
    ),

    // ---- Buyer payments ----
    GetPage(
      name: AppRoutes.paymentInstructions,
      page: () => const PaymentInstructionsPage(),
      binding: PaymentInstructionsBinding(),
    ),
    GetPage(
      name: AppRoutes.submitPaymentEvidence,
      page: () => const SubmitPaymentEvidencePage(),
      binding: SubmitPaymentEvidenceBinding(),
    ),

    // ---- Buyer disputes + reviews ----
    GetPage(
      name: AppRoutes.createDispute,
      page: () => const CreateDisputePage(),
      binding: CreateDisputeBinding(),
    ),
    GetPage(
      name: AppRoutes.disputeDetail,
      page: () => const DisputeDetailPage(),
      binding: DisputeDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.createReview,
      page: () => const CreateReviewPage(),
      binding: CreateReviewBinding(),
    ),

    // new GetPage entries inside routes:
    GetPage(
      name: AppRoutes.submitVerification,
      page: () => const SubmitVerificationPage(),
      binding: SubmitVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.verificationStatus,
      page: () => const VerificationStatusPage(),
      binding: VerificationStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.browseRequests,
      page: () => const BrowseRequestsPage(),
      binding: BrowseRequestsBinding(),
    ),
    GetPage(
      name: AppRoutes.submitQuotation,
      page: () => const SubmitQuotationPage(),
      binding: SubmitQuotationBinding(),
    ),
    GetPage(
      name: AppRoutes.myQuotations,
      page: () => const MyQuotationsPage(),
      binding: MyQuotationsBinding(),
    ),
    GetPage(
      name: AppRoutes.editQuotation,
      page: () => const EditQuotationPage(),
      binding: EditQuotationBinding(),
    ),
    GetPage(
      name: AppRoutes.importerOrders,
      page: () => const ImporterOrdersPage(),
      binding: ImporterOrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.importerOrderDetail,
      page: () => const ImporterOrderDetailPage(),
      binding: ImporterOrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.updateOrderStatus,
      page: () => const UpdateStatusPage(),
      binding: UpdateStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.businessProfile,
      page: () => const BusinessProfilePage(),
      binding: BusinessProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.shipmentTracking,
      page: () => const ShipmentTrackingPage(),
      binding: ShipmentTrackingBinding(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.conversations,
      page: () => const ConversationListPage(),
      binding: ConversationListBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.reportFraud,
      page: () => const ReportFraudPage(),
      binding: ReportFraudBinding(),
    ),
  ];
}
