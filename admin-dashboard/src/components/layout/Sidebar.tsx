import { NavLink } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { AnimatePresence, motion } from 'framer-motion';
import { ChevronsLeft, LogOut, X } from 'lucide-react';
import { NAV_SECTIONS, type BadgeKey } from '@/lib/nav';
import { getReportsSummary } from '@/api/admin.api';
import { useAuth } from '@/features/auth/useAuth';
import { Avatar } from '@/components/pro/Avatar';

function useBadges(): Partial<Record<BadgeKey, number>> {
  const { data } = useQuery({ queryKey: ['reports', 'summary'], queryFn: getReportsSummary, staleTime: 60_000 });
  return {
    pendingImporters: data?.importers.byStatus?.pending ?? 0,
    openDisputes: data?.disputes.open ?? 0,
  };
}

function Brand({ collapsed }: { collapsed: boolean }) {
  return (
    <div className="flex items-center gap-3 px-5 h-[68px] shrink-0">
      <div className="relative shrink-0">
        <span className="absolute inset-0 rounded-2xl bg-emerald-400/40 blur-md" />
        <div className="relative w-10 h-10 rounded-2xl bg-gradient-to-br from-emerald-300 to-emerald-600 flex items-center justify-center text-emerald-950 font-display text-xl shadow-lg">ኢ</div>
      </div>
      <AnimatePresence initial={false}>
        {!collapsed && (
          <motion.div initial={{ opacity: 0, x: -8 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -8 }} transition={{ duration: 0.2 }} className="leading-tight min-w-0">
            <div className="font-display text-lg text-white">EthioMarket</div>
            <div className="text-[10px] uppercase tracking-[0.2em] text-emerald-300/80">Admin console</div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export function SidebarBody({
  collapsed, onNavigate, onToggle,
}: { collapsed: boolean; onNavigate?: () => void; onToggle?: () => void }) {
  const badges = useBadges();
  const { user, logout } = useAuth();

  return (
    <div className="relative h-full flex flex-col bg-emerald-950 text-emerald-50 overflow-hidden">
      {/* ambient background */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute -top-24 -left-24 w-72 h-72 rounded-full bg-emerald-600/30 blur-3xl animate-aurora" />
        <div className="absolute bottom-0 -right-24 w-72 h-72 rounded-full bg-teal-500/20 blur-3xl animate-aurora-rev" />
        <div className="absolute inset-0 bg-grid-light opacity-40 mask-fade-b" />
      </div>

      <div className="relative flex flex-col h-full">
        <Brand collapsed={collapsed} />

        <nav className="flex-1 overflow-y-auto no-scrollbar px-3 pb-4 space-y-4">
          {NAV_SECTIONS.map((section) => (
            <div key={section.title}>
              <AnimatePresence initial={false}>
                {!collapsed ? (
                  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="px-3 pb-1.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-emerald-400/60">
                    {section.title}
                  </motion.div>
                ) : <div className="mx-3 mb-2 h-px bg-white/10" />}
              </AnimatePresence>
              <div className="space-y-px">
                {section.items.map((item) => {
                  const count = item.badge ? badges[item.badge] ?? 0 : 0;
                  return (
                    <NavLink key={item.to} to={item.to} end={item.end} onClick={onNavigate} title={collapsed ? item.label : undefined}
                      className="group relative block rounded-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-400">
                      {({ isActive }) => (
                        <div className={`relative flex items-center gap-3 h-10 rounded-xl transition-colors ${collapsed ? 'justify-center px-0' : 'px-3'} ${isActive ? 'text-white' : 'text-emerald-100/70 hover:text-white hover:bg-white/5'}`}>
                          {isActive && (
                            <motion.span layoutId="nav-active" transition={{ type: 'spring', stiffness: 400, damping: 34 }}
                              className="absolute inset-0 rounded-xl bg-gradient-to-r from-emerald-500/25 to-emerald-400/5 ring-1 ring-emerald-300/20">
                              <span className="absolute left-0 top-2.5 bottom-2.5 w-[3px] rounded-r-full bg-emerald-300 shadow-[0_0_12px_rgba(110,231,183,0.9)]" />
                            </motion.span>
                          )}
                          <span className="relative">
                            <item.icon className={`w-[19px] h-[19px] transition-transform duration-300 group-hover:scale-110 ${isActive ? 'text-emerald-300' : ''}`} />
                            {collapsed && count > 0 && <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-gold-400 ring-2 ring-emerald-950" />}
                          </span>
                          {!collapsed && (
                            <>
                              <span className="relative text-[14px] font-medium flex-1 truncate">{item.label}</span>
                              {count > 0 && (
                                <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} className="relative min-w-[20px] h-5 px-1.5 rounded-full bg-gold-400 text-ink-900 text-[11px] font-bold flex items-center justify-center">
                                  {count}
                                </motion.span>
                              )}
                            </>
                          )}
                        </div>
                      )}
                    </NavLink>
                  );
                })}
              </div>
            </div>
          ))}
        </nav>

        {/* footer */}
        <div className="relative p-3 border-t border-white/10 bg-black/10 backdrop-blur-sm">
          <div className={`flex items-center gap-3 ${collapsed ? 'justify-center' : 'px-2 py-1'}`}>
            <Avatar name={user?.fullName} size={38} />
            {!collapsed && (
              <div className="min-w-0 flex-1">
                <div className="text-sm font-medium text-white truncate">{user?.fullName}</div>
                <div className="text-[11px] text-emerald-300/70 truncate">{user?.email}</div>
              </div>
            )}
            {!collapsed && (
              <button onClick={() => { logout(); window.location.assign('/login'); }} aria-label="Sign out" title="Sign out"
                className="p-2 rounded-lg text-emerald-200/70 hover:text-white hover:bg-white/10 transition-colors">
                <LogOut className="w-4 h-4" />
              </button>
            )}
          </div>
          {onToggle && (
            <button onClick={onToggle} aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
              className="mt-2 w-full h-9 rounded-xl text-emerald-200/70 hover:text-white hover:bg-white/10 flex items-center justify-center gap-2 text-xs transition-colors">
              <ChevronsLeft className={`w-4 h-4 transition-transform duration-300 ${collapsed ? 'rotate-180' : ''}`} />
              {!collapsed && 'Collapse'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

/** Desktop rail (collapsible) + mobile drawer. */
export function Sidebar({
  collapsed, onToggle, mobileOpen, onCloseMobile,
}: { collapsed: boolean; onToggle: () => void; mobileOpen: boolean; onCloseMobile: () => void }) {
  return (
    <>
      <motion.aside
        initial={false} animate={{ width: collapsed ? 84 : 276 }} transition={{ type: 'spring', stiffness: 320, damping: 36 }}
        className="hidden lg:block shrink-0 sticky top-0 h-screen z-40"
      >
        <SidebarBody collapsed={collapsed} onToggle={onToggle} />
      </motion.aside>

      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={onCloseMobile}
              className="lg:hidden fixed inset-0 z-50 bg-emerald-950/60 backdrop-blur-sm" />
            <motion.aside initial={{ x: '-100%' }} animate={{ x: 0 }} exit={{ x: '-100%' }} transition={{ type: 'spring', stiffness: 320, damping: 34 }}
              className="lg:hidden fixed inset-y-0 left-0 z-[55] w-[290px] max-w-[86vw] shadow-elev">
              <button onClick={onCloseMobile} aria-label="Close menu" className="absolute top-5 right-4 z-10 p-2 rounded-lg text-emerald-100 hover:bg-white/10"><X className="w-5 h-5" /></button>
              <SidebarBody collapsed={false} onNavigate={onCloseMobile} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
