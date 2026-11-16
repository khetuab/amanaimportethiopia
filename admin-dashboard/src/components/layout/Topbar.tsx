import { useEffect, useRef, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { ChevronRight, LogOut, Menu, Search, ShieldCheck } from 'lucide-react';
import { useAuth } from '@/features/auth/useAuth';
import { navFor } from '@/lib/nav';
import { Avatar } from '@/components/pro/Avatar';

export function Topbar({ onMenu, onSearch }: { onMenu: () => void; onSearch: () => void }) {
  const { user, logout } = useAuth();
  const nav = useNavigate();
  const { pathname } = useLocation();
  const current = navFor(pathname);
  const isDetail = current ? pathname.replace(/\/+$/, '') !== current.to : false;

  const [menu, setMenu] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const close = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setMenu(false); };
    document.addEventListener('mousedown', close);
    return () => document.removeEventListener('mousedown', close);
  }, []);

  return (
    <header className="sticky top-0 z-30 bg-white/75 backdrop-blur-xl border-b border-ink-200/80">
      <div className="px-4 sm:px-6 lg:px-8 h-16 flex items-center gap-3 max-w-[1500px] mx-auto">
        <button onClick={onMenu} aria-label="Open menu" className="lg:hidden p-2 -ml-2 rounded-xl text-ink-700 hover:bg-ink-100"><Menu className="w-5 h-5" /></button>

        <nav aria-label="Breadcrumb" className="hidden sm:flex items-center gap-1.5 text-sm min-w-0">
          <Link to="/admin" className="text-ink-500 hover:text-emerald-700 transition-colors">Admin</Link>
          {current && current.to !== '/admin' && (
            <>
              <ChevronRight className="w-3.5 h-3.5 text-ink-300" />
              {isDetail ? <Link to={current.to} className="text-ink-500 hover:text-emerald-700 transition-colors">{current.label}</Link> : <span className="font-medium text-ink-900">{current.label}</span>}
            </>
          )}
          {isDetail && (<><ChevronRight className="w-3.5 h-3.5 text-ink-300" /><span className="font-medium text-ink-900">Details</span></>)}
        </nav>
        <div className="sm:hidden font-display text-lg text-emerald-900">{current?.label ?? 'Admin'}</div>

        <div className="flex-1" />

        <button onClick={onSearch} className="group hidden md:flex items-center gap-3 h-10 pl-3.5 pr-2 rounded-2xl bg-ink-50 hover:bg-white border border-ink-200 hover:border-emerald-300 hover:shadow-card text-ink-500 text-sm transition-all w-64">
          <Search className="w-4 h-4 group-hover:text-emerald-600 transition-colors" />
          <span className="flex-1 text-left">Jump to…</span>
          <kbd className="text-[10px] font-medium border border-ink-200 rounded-md px-1.5 py-0.5 bg-white">Ctrl K</kbd>
        </button>
        <button onClick={onSearch} aria-label="Search" className="md:hidden p-2 rounded-xl text-ink-700 hover:bg-ink-100"><Search className="w-5 h-5" /></button>

        <div className="hidden sm:flex items-center gap-1.5 px-3 h-9 rounded-full bg-emerald-50 text-emerald-800 text-xs font-medium ring-1 ring-emerald-200">
          <span className="relative flex w-2 h-2"><span className="absolute inset-0 rounded-full bg-emerald-500 animate-ping-slow" /><span className="relative w-2 h-2 rounded-full bg-emerald-500" /></span>
          Live
        </div>

        <div className="relative" ref={ref}>
          <button onClick={() => setMenu((m) => !m)} className="flex items-center gap-2 rounded-full p-0.5 pr-3 hover:bg-ink-100 transition-colors" aria-haspopup="menu" aria-expanded={menu}>
            <Avatar name={user?.fullName} size={36} />
            <span className="hidden lg:block text-sm font-medium text-ink-800 max-w-[140px] truncate">{user?.fullName}</span>
          </button>
          <AnimatePresence>
            {menu && (
              <motion.div initial={{ opacity: 0, y: -8, scale: 0.96 }} animate={{ opacity: 1, y: 0, scale: 1 }} exit={{ opacity: 0, y: -6, scale: 0.97 }} transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                role="menu" className="absolute right-0 mt-2 w-64 rounded-2xl bg-white border border-ink-200 shadow-elev p-2 origin-top-right">
                <div className="flex items-center gap-3 p-3">
                  <Avatar name={user?.fullName} size={42} />
                  <div className="min-w-0">
                    <div className="text-sm font-semibold text-ink-900 truncate">{user?.fullName}</div>
                    <div className="text-xs text-ink-500 truncate">{user?.email}</div>
                  </div>
                </div>
                <div className="mx-3 mb-2 inline-flex items-center gap-1.5 text-[11px] font-medium text-emerald-700 bg-emerald-50 rounded-full px-2.5 py-1"><ShieldCheck className="w-3.5 h-3.5" /> Administrator</div>
                <button role="menuitem" onClick={() => { setMenu(false); logout(); nav('/login'); }}
                  className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-sm text-red-600 hover:bg-red-50 transition-colors">
                  <LogOut className="w-4 h-4" /> Sign out
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </header>
  );
}
