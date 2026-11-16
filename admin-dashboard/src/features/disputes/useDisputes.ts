import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { getDispute, listDisputes, resolveDispute } from '@/api/disputes.api';

export function useDisputesList(params: { status?: string; page?: number; limit?: number } = {}) {
  return useQuery({ queryKey: ['disputes', params], queryFn: () => listDisputes(params) });
}

export function useDispute(id: string) {
  return useQuery({ queryKey: ['dispute', id], queryFn: () => getDispute(id), enabled: !!id });
}

export function useResolveDispute(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: { outcome: 'resolved_buyer_favor' | 'resolved_importer_favor' | 'resolved_mutual'; notes?: string; refundPromisedETB?: number }) =>
      resolveDispute(id, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['dispute', id] });
      qc.invalidateQueries({ queryKey: ['disputes'] });
    },
  });
}