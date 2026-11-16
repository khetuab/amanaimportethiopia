import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export type DisputeStatus = 'open' | 'under_review' | 'resolved_buyer_favor' | 'resolved_importer_favor' | 'resolved_mutual' | 'withdrawn';
export type DisputeReason =
  | 'non_delivery' | 'damaged_goods' | 'incorrect_product' | 'spec_mismatch'
  | 'excessive_delay' | 'unapproved_charges' | 'cancellation' | 'payment_evidence' | 'other';

export interface Dispute {
  _id: string;
  order: string | { _id: string; referenceNumber: string; status: string; totalPriceETB: number };
  openedBy: string | { _id: string; fullName: string; email: string; role: string };
  openedByRole: 'buyer' | 'importer';
  reason: DisputeReason;
  description: string;
  status: DisputeStatus;
  evidence: { key: string; url: string; mimeType?: string | null; description?: string }[];
  messages: { author: string; authorRole: string; body: string; at: string }[];
  resolution?: {
    outcome: DisputeStatus; resolvedBy: string; resolvedAt: string;
    notes?: string; refundPromisedETB?: number | null;
  } | null;
  createdAt: string;
}

export async function listDisputes(params: { status?: string; page?: number; limit?: number } = {}) {
  const res = await api.get<ApiSuccess<Dispute[]> & { meta: { pagination: Paginated<Dispute>['meta'] } }>(
    '/admin/disputes', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function getDispute(id: string) {
  const res = await api.get<ApiSuccess<Dispute>>(`/admin/disputes/${id}`);
  return res.data.data;
}

export async function resolveDispute(
  id: string,
  body: { outcome: 'resolved_buyer_favor' | 'resolved_importer_favor' | 'resolved_mutual'; notes?: string; refundPromisedETB?: number },
) {
  const res = await api.post<ApiSuccess<Dispute>>(`/admin/disputes/${id}/resolve`, body);
  return res.data.data;
}