import { api } from './client';
import type { ApiSuccess, Paginated } from '@/types/api.types';
import type { Order, OrderStatus } from '@/types/order.types';

export async function listOrders(params: {
  status?: OrderStatus;
  page?: number;
  limit?: number;
  buyerId?: string;
  importerId?: string;
} = {}) {
  const res = await api.get<ApiSuccess<Order[]> & { meta: { pagination: Paginated<Order>['meta'] } }>(
    '/admin/orders', { params },
  );
  return { items: res.data.data, meta: res.data.meta!.pagination };
}

export async function getOrder(id: string) {
  const res = await api.get<ApiSuccess<Order>>(`/admin/orders/${id}`);
  return res.data.data;
}

export async function adminTransitionOrder(id: string, to: OrderStatus, note?: string) {
  const res = await api.post<ApiSuccess<Order>>(`/admin/orders/${id}/transition`, { to, note });
  return res.data.data;
}

export interface OrderMessage {
  _id: string;
  body: string;
  senderRole: string;
  createdAt: string;
  sender?: { fullName?: string };
}

export async function getOrderMessages(orderId: string) {
  const res = await api.get<ApiSuccess<{
    conversation: { _id: string; lastMessageAt?: string | null };
    messages: OrderMessage[];
  }>>(`/admin/orders/${orderId}/messages`);
  return res.data.data;
}

export async function adminSendOrderMessage(orderId: string, body: string) {
  const res = await api.post<ApiSuccess<{
    _id: string;
    body: string;
    senderRole: string;
    createdAt: string;
    sender?: { fullName?: string };
  }>>(`/admin/orders/${orderId}/messages`, { body });
  return res.data.data;
}