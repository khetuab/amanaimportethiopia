import { api } from './client';
import type { ApiSuccess } from '@/types/api.types';
import type { TokenPair, UserPublic } from '@/types/user.types';

export async function login(identifier: string, password: string) {
  const res = await api.post<ApiSuccess<{ user: UserPublic; tokens: TokenPair }>>('/auth/login', { identifier, password });
  return res.data.data;
}

export async function me() {
  const res = await api.get<ApiSuccess<UserPublic>>('/auth/me');
  return res.data.data;
}