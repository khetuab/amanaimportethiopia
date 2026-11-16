import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';

export interface AdminQuotation {
  _id: string;
  referenceNumber: string;
  request:
    | string
    | {
        _id: string;
        referenceNumber: string;
        title: string;
        status: string;
        deliveryCity: string;
        buyer?: { fullName: string; email: string };
      };
  importerProfile?:
    | string
    | {
        businessName: string;
        verificationStatus: string;
        ratingAverage?: number;
      };
  importerUser?:
    | string
    | { fullName: string; email: string; phone: string };
  totalPriceETB: number;
  productCondition: string;
  estimatedDeliveryDays: number;
  quotationValidUntil: string;
  status: string;
  createdAt: string;
}

export interface AdminListQuotationsParams {
  status?: string;
  requestId?: string;
  importerUserId?: string;
  importerProfileId?: string;
  page?: number;
  limit?: number;
}

export async function adminListQuotations(params: AdminListQuotationsParams = {}) {
  const res = await api.get<
    ApiSuccess<AdminQuotation[]> & { meta: { pagination: Paginated<AdminQuotation>['meta'] } }
  >('/admin/quotations', { params });
  return { items: res.data.data, meta: res.data.meta!.pagination };
}