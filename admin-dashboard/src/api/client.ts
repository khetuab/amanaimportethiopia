import axios, { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { toast } from 'sonner';

const ACCESS_KEY = 'ethio.admin.access';
const REFRESH_KEY = 'ethio.admin.refresh';
const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';

export const tokenStore = {
  getAccess: () => sessionStorage.getItem(ACCESS_KEY),
  getRefresh: () => sessionStorage.getItem(REFRESH_KEY),
  set: (access: string, refresh: string) => {
    sessionStorage.setItem(ACCESS_KEY, access);
    sessionStorage.setItem(REFRESH_KEY, refresh);
  },
  clear: () => {
    sessionStorage.removeItem(ACCESS_KEY);
    sessionStorage.removeItem(REFRESH_KEY);
  },
};

export const api: AxiosInstance = axios.create({ baseURL: BASE_URL, timeout: 20000 });

let refreshing: Promise<string | null> | null = null;
async function refreshToken(): Promise<string | null> {
  const refresh = tokenStore.getRefresh();
  if (!refresh) return null;
  try {
    const res = await axios.post(`${BASE_URL}/auth/refresh`, { refreshToken: refresh });
    const { accessToken, refreshToken: newRefresh } = res.data.data.tokens;
    tokenStore.set(accessToken, newRefresh);
    return accessToken;
  } catch {
    tokenStore.clear();
    return null;
  }
}

api.interceptors.request.use((cfg: InternalAxiosRequestConfig) => {
  const token = tokenStore.getAccess();
  if (token) cfg.headers.Authorization = `Bearer ${token}`;
  return cfg;
});

api.interceptors.response.use(
  (r) => r,
  async (err: AxiosError<{ error?: { code?: string; message?: string } }>) => {
    const status = err.response?.status;
    const original = err.config as InternalAxiosRequestConfig & { _retry?: boolean };
    if (status === 401 && !original._retry) {
      original._retry = true;
      refreshing = refreshing ?? refreshToken();
      const newToken = await refreshing;
      refreshing = null;
      if (newToken) {
        original.headers.Authorization = `Bearer ${newToken}`;
        return api(original);
      }
      window.dispatchEvent(new CustomEvent('ethio:force-logout'));
    }
    if (status !== 401) {
      toast.error(err.response?.data?.error?.message || err.message || 'Request failed');
    }
    return Promise.reject(err);
  },
);

export function apiErrorMessage(err: unknown): string {
  if (axios.isAxiosError(err)) return err.response?.data?.error?.message || err.message;
  return err instanceof Error ? err.message : 'Unexpected error';
}