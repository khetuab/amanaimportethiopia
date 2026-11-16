import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export interface ReportsSummary {
  requests: {
    total: number;
    byStatus: Record<string, number>;
    byCategory: { categoryId: string; name?: string; count: number }[];
  };
  conversions: {
    requests: number; quotations: number; orders: number; acceptedQuotes: number;
    avgQuotationsPerRequest: number; requestToQuoteRate: number; requestToOrderRate: number;
  };
  revenue: {
    pending: { count: number; total: number };
    invoiced: { count: number; total: number };
    received: { count: number; total: number };
    waived: { count: number; total: number };
    refunded: { count: number; total: number };
    verifiedPayments: { count: number; total: number };
  };
  disputes: { total: number; open: number; byStatus: Record<string, number>; byReason: { _id: string; count: number }[] };
  importers: {
    byStatus: Record<string, number>;
    top: { _id: string; businessName: string; completedOrdersCount: number; ratingAverage: number; ratingCount: number }[];
  };
}

export interface AuditLogEntry {
  _id: string;
  actor: { _id: string; fullName: string; email: string; role: string } | string;
  actorRole: string;
  action: string;
  targetType: string;
  targetId: string;
  summary?: string;
  createdAt: string;
}

export interface FraudReport {
  _id: string;
  category: string;
  description: string;
  status: 'open' | 'investigating' | 'resolved_no_action' | 'resolved_action_taken';
  reporter?: { fullName?: string; email?: string; role?: string } | null;
  relatedUser?: { fullName?: string; email?: string; role?: string } | null;
  relatedOrder?: { referenceNumber?: string; status?: string } | null;
  adminNotes?: string;
  createdAt: string;
}

export interface LegalChecklistItem {
  _id: string;
  item: string;
  label: string;
  category: string;
  status: 'not_started' | 'in_review' | 'advice_obtained' | 'enabled';
  gatesCapability?: string | null;
  notes?: string;
  legalAdviceReference?: string;
  reviewedAt?: string | null;
}

export async function getReportsSummary() {
  const res = await api.get<ApiSuccess<ReportsSummary>>('/admin/reports/summary');
  return res.data.data;
}

export async function listAudit(params: {
  actor?: string; action?: string; targetType?: string; from?: string; to?: string;
  page?: number; limit?: number;
} = {}) {
  const res = await api.get<ApiSuccess<AuditLogEntry[]> & { meta: { pagination: Paginated<AuditLogEntry>['meta'] } }>(
    '/admin/audit', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function listFraudReports(params: { status?: string; category?: string; page?: number; limit?: number } = {}) {
  const res = await api.get<ApiSuccess<FraudReport[]> & { meta: { pagination: Paginated<FraudReport>['meta'] } }>(
    '/admin/fraud-reports', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function updateFraudReport(id: string, body: { status: string; notes?: string }) {
  const res = await api.patch<ApiSuccess<FraudReport>>(`/admin/fraud-reports/${id}`, body);
  return res.data.data;
}

export async function listLegalChecklist() {
  const res = await api.get<ApiSuccess<LegalChecklistItem[]>>('/admin/legal-checklist');
  return res.data.data;
}

export async function updateLegalChecklist(item: string, body: { status: LegalChecklistItem['status']; notes?: string }) {
  const res = await api.patch<ApiSuccess<LegalChecklistItem>>(`/admin/legal-checklist/${item}`, body);
  return res.data.data;
}