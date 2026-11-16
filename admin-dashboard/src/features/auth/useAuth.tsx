import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { tokenStore } from '@/api/client';
import * as authApi from '@/api/auth.api';
import type { UserPublic } from '@/types/user.types';

interface AuthCtx {
  user: UserPublic | null;
  loading: boolean;
  login: (identifier: string, password: string) => Promise<void>;
  logout: () => void;
}

const Ctx = createContext<AuthCtx | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserPublic | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      if (!tokenStore.getAccess()) { setLoading(false); return; }
      try {
        const u = await authApi.me();
        if (!cancelled) setUser(u);
      } catch { tokenStore.clear(); } finally { if (!cancelled) setLoading(false); }
    })();
    const onForceLogout = () => { tokenStore.clear(); setUser(null); };
    window.addEventListener('ethio:force-logout', onForceLogout);
    return () => { cancelled = true; window.removeEventListener('ethio:force-logout', onForceLogout); };
  }, []);

  const value = useMemo<AuthCtx>(() => ({
    user, loading,
    async login(identifier, password) {
      const data = await authApi.login(identifier, password);
      if (data.user.role !== 'admin') throw new Error('This account is not an administrator.');
      tokenStore.set(data.tokens.accessToken, data.tokens.refreshToken);
      setUser(data.user);
    },
    logout() { tokenStore.clear(); setUser(null); },
  }), [user, loading]);

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAuth() {
  const v = useContext(Ctx);
  if (!v) throw new Error('useAuth outside AuthProvider');
  return v;
}