import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export interface CommissionRule {
  _id: string;
  name: string;
  version: string;
  feeType: 'percentage' | 'fixed';
  percentage?: number | null;
  fixedAmountETB?: number | null;
  minFeeETB?: number | null;
  maxFeeETB?: number | null;
  payer: 'buyer' | 'importer';
  categoryIds: string[];
  effectiveFrom: string;
  effectiveUntil?: string | null;
  isActive: boolean;
  description?: string;
}

export interface CommissionRecord {
  _id: string;
  order: { _id: string; referenceNumber: string; status: string; totalPriceETB: number } | string;
  ruleVersion: string;
  feeType: string;
  payer: string;
  orderValueETB: number;
  computedFeeETB: number;
  revenueState: 'pending' | 'invoiced' | 'received' | 'waived' | 'refunded';
  createdAt: string;
}

export interface RevenueSummary {
  pending: { count: number; total: number };
  invoiced: { count: number; total: number };
  received: { count: number; total: number };
  waived: { count: number; total: number };
  refunded: { count: number; total: number };
}

export async function listCommissionRules() {
  const res = await api.get<ApiSuccess<CommissionRule[]>>('/admin/commission-rules');
  return res.data.data;
}

export async function createCommissionRule(body: Partial<CommissionRule>) {
  const res = await api.post<ApiSuccess<CommissionRule>>('/admin/commission-rules', body);
  return res.data.data;
}

export async function deactivateCommissionRule(id: string) {
  const res = await api.delete<ApiSuccess<unknown>>(`/admin/commission-rules/${id}`);
  return res.data.data;
}

export async function listCommissionRecords(params: { revenueState?: string; page?: number; limit?: number } = {}) {
  const res = await api.get<ApiSuccess<CommissionRecord[]> & { meta: { pagination: Paginated<CommissionRecord>['meta'] } }>(
    '/admin/commission-records', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function getRevenueSummary() {
  const res = await api.get<ApiSuccess<RevenueSummary>>('/admin/revenue/summary');
  return res.data.data;
}

export async function transitionRevenueState(id: string, to: string) {
  const res = await api.post<ApiSuccess<CommissionRecord>>(
    `/admin/commission-records/${id}/transition`, { to },
  );
  return res.data.data;
}