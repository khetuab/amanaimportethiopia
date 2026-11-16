import { useQuery } from '@tanstack/react-query';
import { listAudit } from '@/api/admin.api';

export function useAuditLogs(params: { action?: string; page?: number; limit?: number } = {}) {
  return useQuery({ queryKey: ['audit', params], queryFn: () => listAudit(params) });
}