import { api } from './client';
import type { ApiSuccess } from '@/types/api.types';

export interface Category {
  _id: string;
  name: string;
  slug: string;
  description?: string;
  parentId?: string | null;
  isActive: boolean;
  isRestricted: boolean;
  sortOrder: number;
}

export async function listCategories() {
  const res = await api.get<ApiSuccess<Category[]>>('/categories');
  return res.data.data;
}

export async function createCategory(body: { name: string; description?: string; parentId?: string | null }) {
  const res = await api.post<ApiSuccess<Category>>('/categories', body);
  return res.data.data;
}

export async function updateCategory(id: string, patch: Partial<Category>) {
  const res = await api.patch<ApiSuccess<Category>>(`/categories/${id}`, patch);
  return res.data.data;
}

export async function deleteCategory(id: string) {
  const res = await api.delete<ApiSuccess<unknown>>(`/categories/${id}`);
  return res.data.data;
}