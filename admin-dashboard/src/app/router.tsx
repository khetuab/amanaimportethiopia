import { createBrowserRouter, Navigate } from 'react-router-dom';
import { ProtectedRoute } from '@/components/common/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import LoginPage from '@/features/auth/LoginPage';
import DashboardPage from '@/features/dashboard/DashboardPage';
import ImportersPage from '@/features/importers/ImportersPage';
import ImporterDetailPage from '@/features/importers/ImporterDetailPage';
import VerificationReviewPage from '@/features/importers/VerificationReviewPage';
import PaymentsPage from '@/features/payments/PaymentsPage';
import PaymentReviewPage from '@/features/payments/PaymentReviewPage';
import OrdersPage from '@/features/orders/OrdersPage';
import OrderDetailPage from '@/features/orders/OrderDetailPage';
import DisputesPage from '@/features/disputes/DisputesPage';
import DisputeDetailPage from '@/features/disputes/DisputeDetailPage';
import CommissionRulesPage from '@/features/commissions/CommissionRulesPage';
import ReconciliationPage from '@/features/commissions/ReconciliationPage';
import AuditLogsPage from '@/features/audit/AuditLogsPage';
import SettingsPage from '@/features/settings/SettingsPage';
import UsersPage from '@/features/users/UsersPage';
import UserDetailPage from '@/features/users/UserDetailPage';
import CategoriesPage from '@/features/categories/CategoriesPage';
import RequestsPage from '@/features/requests/RequestsPage';
import QuotationsPage from '@/features/quotations/QuotationsPage';
import FraudPage from '@/features/fraud/FraudPage';
import NotFound from '@/features/NotFound';

export const router = createBrowserRouter([
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '/login', element: <LoginPage /> },
  {
    path: '/admin',
    element: <ProtectedRoute />,
    children: [
      {
        element: <DashboardLayout />,
        children: [
          { index: true, element: <DashboardPage /> },
          { path: 'importers', element: <ImportersPage /> },
          { path: 'importers/:id', element: <ImporterDetailPage /> },
          { path: 'importers/:id/review', element: <VerificationReviewPage /> },
          { path: 'payments', element: <PaymentsPage /> },
          { path: 'payments/:id', element: <PaymentReviewPage /> },
          { path: 'orders', element: <OrdersPage /> },
          { path: 'orders/:id', element: <OrderDetailPage /> },
          { path: 'disputes', element: <DisputesPage /> },
          { path: 'disputes/:id', element: <DisputeDetailPage /> },
          { path: 'categories', element: <CategoriesPage /> },
          { path: 'requests', element: <RequestsPage /> },
          { path: 'quotations', element: <QuotationsPage /> },
          { path: 'commissions/rules', element: <CommissionRulesPage /> },
          { path: 'commissions/reconciliation', element: <ReconciliationPage /> },
          { path: 'audit', element: <AuditLogsPage /> },
          { path: 'settings', element: <SettingsPage /> },
          { path: 'users', element: <UsersPage /> },
          { path: 'users/:id', element: <UserDetailPage /> },
          { path: 'fraud', element: <FraudPage /> },
          { path: '*', element: <NotFound /> },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/login" replace /> },
]);