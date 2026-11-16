import { useQuery } from '@tanstack/react-query';
import { adminListQuotations, type AdminListQuotationsParams } from '@/api/quotations.api';

export function useAdminQuotations(params: AdminListQuotationsParams = {}) {
  return useQuery({
    queryKey: ['admin-quotations', params],
    queryFn: () => adminListQuotations(params),
  });
}