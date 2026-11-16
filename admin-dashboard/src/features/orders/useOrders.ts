import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  adminTransitionOrder, getOrder, getOrderMessages, listOrders,
} from '@/api/orders.api';
import type { OrderStatus } from '@/types/order.types';

export function useOrdersList(params: { status?: OrderStatus; limit?: number } = {}) {
  return useQuery({ queryKey: ['orders', params], queryFn: () => listOrders(params) });
}

export function useOrder(id: string) {
  return useQuery({ queryKey: ['order', id], queryFn: () => getOrder(id), enabled: !!id });
}

export function useOrderMessages(id: string, enabled = false) {
  return useQuery({ queryKey: ['order-messages', id], queryFn: () => getOrderMessages(id), enabled });
}

export function useTransitionOrder(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ to, note }: { to: OrderStatus; note?: string }) => adminTransitionOrder(id, to, note),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['order', id] });
      qc.invalidateQueries({ queryKey: ['orders'] });
    },
  });
}