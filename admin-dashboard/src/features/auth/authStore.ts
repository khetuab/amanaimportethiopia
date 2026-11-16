// Non-React helpers for external callers (e.g. force logout handler)
import { tokenStore } from '@/api/client';

export const authStore = {
  clear: () => tokenStore.clear(),
  hasSession: () => Boolean(tokenStore.getAccess()),
};