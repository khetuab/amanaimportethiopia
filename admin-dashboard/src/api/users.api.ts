import { api } from './client';
import type { ApiSuccess } from '@/types/api.types';
import type { UserPublic } from '@/types/user.types';

export async function getMe() {
  const res = await api.get<ApiSuccess<UserPublic>>('/users/me');
  return res.data.data;
}

export async function updateMe(patch: Partial<Pick<UserPublic, 'fullName' | 'preferredLanguage'>>) {
  const res = await api.patch<ApiSuccess<UserPublic>>('/users/me', patch);
  return res.data.data;
}