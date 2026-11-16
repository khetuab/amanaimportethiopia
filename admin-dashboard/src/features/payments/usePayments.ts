import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { listPayments, reviewPayment } from '@/api/payments.api';

export function usePaymentsList(params: { status?: string; page?: number; limit?: number } = {}) {
  return useQuery({ queryKey: ['payments', params], queryFn: () => listPayments(params) });
}

export function useReviewPayment() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, action, note, rejectionReason }: {
      id: string; action: 'verify' | 'reject' | 'reverse' | 'dispute'; note?: string; rejectionReason?: string;
    }) => reviewPayment(id, { action, note, rejectionReason }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['payments'] }),
  });
}