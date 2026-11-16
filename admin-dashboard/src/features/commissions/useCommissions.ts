import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  createCommissionRule, deactivateCommissionRule, getRevenueSummary,
  listCommissionRecords, listCommissionRules, transitionRevenueState,
  type CommissionRule,
} from '@/api/commissions.api';

export function useCommissionRules() {
  return useQuery({ queryKey: ['commission-rules'], queryFn: listCommissionRules });
}

export function useCreateCommissionRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: Partial<CommissionRule>) => createCommissionRule(body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['commission-rules'] }),
  });
}

export function useDeactivateCommissionRule() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => deactivateCommissionRule(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['commission-rules'] }),
  });
}

export function useCommissionRecords(params: { revenueState?: string } = {}) {
  return useQuery({ queryKey: ['commission-records', params], queryFn: () => listCommissionRecords(params) });
}

export function useRevenueSummary() {
  return useQuery({ queryKey: ['revenue-summary'], queryFn: getRevenueSummary });
}

export function useTransitionRevenue() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, to }: { id: string; to: string }) => transitionRevenueState(id, to),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['commission-records'] }),
  });
}