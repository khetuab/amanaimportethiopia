import { api } from './client';
import type { ApiSuccess } from '@/types/api.types';
import type { ImporterProfile, VerificationDocument, VerificationStatus } from '@/types/importer.types';

export async function listImporters(params: { status?: VerificationStatus; q?: string } = {}) {
  const res = await api.get<ApiSuccess<ImporterProfile[]>>('/admin/importers', { params });
  return res.data.data;
}

export async function getImporter(id: string) {
  const res = await api.get<ApiSuccess<{ profile: ImporterProfile; documents: VerificationDocument[] }>>(
    `/admin/importers/${id}`,
  );
  return res.data.data;
}

export async function reviewImporter(
  id: string,
  body: { action: 'approve' | 'reject' | 'suspend' | 'reinstate' | 'expire'; notes?: string },
) {
  const res = await api.patch<ApiSuccess<ImporterProfile>>(`/admin/importers/${id}/review`, body);
  return res.data.data;
}