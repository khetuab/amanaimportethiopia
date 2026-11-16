import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  createCategory, deleteCategory, listCategories, updateCategory, type Category,
} from '@/api/categories.api';

export function useCategoriesList() {
  return useQuery({ queryKey: ['categories'], queryFn: listCategories });
}

export function useCreateCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: { name: string; description?: string; parentId?: string | null }) => createCategory(body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categories'] }),
  });
}

export function useUpdateCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, patch }: { id: string; patch: Partial<Category> }) => updateCategory(id, patch),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categories'] }),
  });
}

export function useDeleteCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => deleteCategory(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['categories'] }),
  });
}