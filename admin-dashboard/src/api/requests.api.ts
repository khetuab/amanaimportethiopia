import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export interface AdminProductRequest {
  _id: string;
  referenceNumber: string;
  title: string;
  description: string;
  status: string;
  deliveryCity: string;
  quantity: number;
  unitOfMeasurement: string;
  budgetMinETB?: number | null;
  budgetMaxETB?: number | null;
  expiresAt: string;
  quotationsCount: number;
  createdAt: string;
  category?: { _id: string; name: string; slug: string } | null;
  buyer?: { _id: string; fullName: string; email: string; phone: string } | null;
}

export interface AdminListRequestsParams {
  status?: string;
  category?: string;
  city?: string;
  buyerId?: string;
  q?: string;
  page?: number;
  limit?: number;
}

export async function adminListRequests(params: AdminListRequestsParams = {}) {
  const res = await api.get<
    ApiSuccess<AdminProductRequest[]> & { meta: { pagination: Paginated<AdminProductRequest>['meta'] } }
  >('/admin/requests', { params });
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function adminGetRequest(id: string) {
  const res = await api.get<ApiSuccess<AdminProductRequest>>(`/admin/requests/${id}`);
  return res.data.data;
}