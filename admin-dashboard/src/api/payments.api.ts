import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export type PaymentStatus = 'submitted' | 'verified' | 'rejected' | 'reversed' | 'disputed';

export interface PaymentRecord {
  _id: string;
  order: string | { _id: string; referenceNumber: string; status: string; totalPriceETB: number };
  buyer: string | { _id: string; fullName: string; email: string; phone: string };
  transactionReference: string;
  amountETB: number;
  paymentChannel: string;
  paidAt: string;
  receiptKey?: string | null;
  receiptUrl?: string | null;
  receiptViewUrl?: string | null; // signed/ready-to-display URL computed by the backend
  receiptMimeType?: string | null;
  status: PaymentStatus;
  isVerified: boolean;
  rejectionReason?: string;
  reviewedBy?: { fullName: string; email: string } | null;
  reviewedAt?: string | null;
  reviewHistory: { action: string; actor: string; actorRole: string; note?: string; at: string }[];
  createdAt: string;
}

export async function listPayments(params: { status?: string; page?: number; limit?: number } = {}) {
  const res = await api.get<ApiSuccess<PaymentRecord[]> & { meta: { pagination: Paginated<PaymentRecord>['meta'] } }>(
    '/admin/payments', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function getPayment(id: string) {
  const res = await api.get<ApiSuccess<PaymentRecord>>(`/admin/payments/${id}`);
  return res.data.data;
}

export async function reviewPayment(
  id: string,
  body: { action: 'verify' | 'reject' | 'reverse' | 'dispute'; note?: string; rejectionReason?: string },
) {
  const res = await api.post<ApiSuccess<PaymentRecord>>(`/admin/payments/${id}/review`, body);
  return res.data.data;
}