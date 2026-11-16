import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { listLegalChecklist, updateLegalChecklist, type LegalChecklistItem } from '@/api/admin.api';

export function useLegalChecklist() {
  return useQuery({ queryKey: ['legal'], queryFn: listLegalChecklist });
}

export function useUpdateLegalItem() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ item, status }: { item: string; status: LegalChecklistItem['status'] }) =>
      updateLegalChecklist(item, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['legal'] }),
  });
}