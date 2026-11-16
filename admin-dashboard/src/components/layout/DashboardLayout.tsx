import { useEffect, useState } from 'react';
import { useLocation, useOutlet } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { TopLoader } from '@/components/pro/TopLoader';
import { CommandPalette } from '@/components/pro/CommandPalette';

const COLLAPSE_KEY = 'ethio:sidebar-collapsed';

export function DashboardLayout() {
  const { pathname } = useLocation();
  const outlet = useOutlet();
  const [collapsed, setCollapsed] = useState(() => localStorage.getItem(COLLAPSE_KEY) === '1');
  const [mobileOpen, setMobileOpen] = useState(false);
  const [palette, setPalette] = useState(false);

  const toggle = () => setCollapsed((c) => { localStorage.setItem(COLLAPSE_KEY, c ? '0' : '1'); return !c; });

  useEffect(() => { setMobileOpen(false); window.scrollTo({ top: 0 }); }, [pathname]);
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); setPalette((p) => !p); }
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  return (
    <div className="min-h-screen flex bg-ink-50 bg-dots-soft">
      <TopLoader />
      <Sidebar collapsed={collapsed} onToggle={toggle} mobileOpen={mobileOpen} onCloseMobile={() => setMobileOpen(false)} />
      <div className="flex-1 flex flex-col min-w-0">
        <Topbar onMenu={() => setMobileOpen(true)} onSearch={() => setPalette(true)} />
        <AnimatePresence mode="wait" initial={false}>
          <motion.main
            key={pathname}
            initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.25, ease: [0.22, 1, 0.36, 1] }}
            className="flex-1 p-4 sm:p-6 lg:p-8 max-w-[1500px] w-full mx-auto"
          >
            {outlet}
          </motion.main>
        </AnimatePresence>
      </div>
      <CommandPalette open={palette} onClose={() => setPalette(false)} />
    </div>
  );
}
