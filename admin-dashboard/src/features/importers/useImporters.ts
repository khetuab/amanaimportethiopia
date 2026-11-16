import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { getImporter, listImporters, reviewImporter } from '@/api/importers.api';
import type { VerificationStatus } from '@/types/importer.types';

export function useImportersList(params: { status?: VerificationStatus; q?: string }) {
  return useQuery({ queryKey: ['importers', params], queryFn: () => listImporters(params) });
}

export function useImporter(id: string) {
  return useQuery({ queryKey: ['importer', id], queryFn: () => getImporter(id), enabled: !!id });
}

export function useReviewImporter(id: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: { action: 'approve' | 'reject' | 'suspend' | 'reinstate' | 'expire'; notes?: string }) =>
      reviewImporter(id, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['importer', id] });
      qc.invalidateQueries({ queryKey: ['importers'] });
    },
  });
}