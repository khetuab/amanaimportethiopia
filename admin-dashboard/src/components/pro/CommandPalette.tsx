import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { CornerDownLeft, Search } from 'lucide-react';
import { NAV_SECTIONS } from '@/lib/nav';

export function CommandPalette({ open, onClose }: { open: boolean; onClose: () => void }) {
  const nav = useNavigate();
  const [q, setQ] = useState('');
  const [idx, setIdx] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  const groups = useMemo(() => {
    const needle = q.trim().toLowerCase();
    return NAV_SECTIONS.map((s) => ({
      title: s.title,
      items: s.items.filter((i) => !needle || `${i.label} ${i.hint}`.toLowerCase().includes(needle)),
    })).filter((g) => g.items.length);
  }, [q]);
  const flat = useMemo(() => groups.flatMap((g) => g.items), [groups]);

  useEffect(() => { if (open) { setQ(''); setIdx(0); setTimeout(() => inputRef.current?.focus(), 30); } }, [open]);
  useEffect(() => { setIdx(0); }, [q]);

  const go = (to: string) => { onClose(); nav(to); };

  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setIdx((i) => Math.min(i + 1, flat.length - 1)); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setIdx((i) => Math.max(i - 1, 0)); }
    else if (e.key === 'Enter' && flat[idx]) { e.preventDefault(); go(flat[idx].to); }
    else if (e.key === 'Escape') onClose();
  };

  let n = -1;
  return (
    <AnimatePresence>
      {open && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          className="fixed inset-0 z-[70] bg-ink-950/50 backdrop-blur-sm flex items-start justify-center pt-[14vh] px-4" onClick={onClose}>
          <motion.div initial={{ opacity: 0, y: -12, scale: 0.97 }} animate={{ opacity: 1, y: 0, scale: 1 }} exit={{ opacity: 0, y: -8, scale: 0.97 }}
            transition={{ type: 'spring', stiffness: 360, damping: 30 }}
            className="w-full max-w-xl rounded-3xl bg-white shadow-elev border border-ink-200 overflow-hidden" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center gap-3 px-5 h-14 border-b border-ink-100">
              <Search className="w-5 h-5 text-emerald-600" />
              <input ref={inputRef} value={q} onChange={(e) => setQ(e.target.value)} onKeyDown={onKey} placeholder="Jump to a page…"
                className="flex-1 bg-transparent outline-none text-[15px] placeholder:text-ink-400" />
              <kbd className="text-[10px] font-medium text-ink-400 border border-ink-200 rounded-md px-1.5 py-0.5">ESC</kbd>
            </div>
            <div className="max-h-[52vh] overflow-y-auto p-2 scrollbar-thin">
              {flat.length === 0 && <div className="py-10 text-center text-sm text-ink-500">No pages match “{q}”.</div>}
              {groups.map((g) => (
                <div key={g.title} className="mb-1">
                  <div className="px-3 pt-2 pb-1 text-[10px] uppercase tracking-wider text-ink-400">{g.title}</div>
                  {g.items.map((it) => {
                    n += 1;
                    const my = n;
                    const active = my === idx;
                    return (
                      <button key={it.to} onMouseEnter={() => setIdx(my)} onClick={() => go(it.to)}
                        className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-2xl text-left transition-colors ${active ? 'bg-emerald-50' : ''}`}>
                        <span className={`w-9 h-9 rounded-xl flex items-center justify-center transition-colors ${active ? 'bg-emerald-600 text-white' : 'bg-ink-100 text-ink-600'}`}><it.icon className="w-[18px] h-[18px]" /></span>
                        <span className="flex-1 min-w-0">
                          <span className="block text-sm font-medium text-ink-900">{it.label}</span>
                          <span className="block text-xs text-ink-500 truncate">{it.hint}</span>
                        </span>
                        {active && <CornerDownLeft className="w-4 h-4 text-emerald-600" />}
                      </button>
                    );
                  })}
                </div>
              ))}
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
