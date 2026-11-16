import { useQuery } from '@tanstack/react-query';
import { adminListRequests, type AdminListRequestsParams } from '@/api/requests.api';

export function useAdminRequests(params: AdminListRequestsParams = {}) {
  return useQuery({
    queryKey: ['admin-requests', params],
    queryFn: () => adminListRequests(params),
  });
}