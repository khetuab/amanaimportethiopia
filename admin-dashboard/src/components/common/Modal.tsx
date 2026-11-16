import { AnimatePresence, motion } from 'framer-motion';
import { X, type LucideIcon } from 'lucide-react';
import { useEffect } from 'react';

export function Modal({
  open, onClose, title, children, footer, width = 'max-w-lg', icon: Icon, subtitle,
}: {
  open: boolean; onClose: () => void; title: React.ReactNode;
  children: React.ReactNode; footer?: React.ReactNode; width?: string;
  icon?: LucideIcon; subtitle?: React.ReactNode;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    if (open) {
      document.addEventListener('keydown', onKey);
      const prev = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      return () => { document.removeEventListener('keydown', onKey); document.body.style.overflow = prev; };
    }
  }, [open, onClose]);

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 bg-emerald-950/50 backdrop-blur-md flex items-center justify-center p-4"
          onClick={onClose}
        >
          <motion.div
            role="dialog" aria-modal="true"
            initial={{ opacity: 0, y: 24, scale: 0.96 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 12, scale: 0.97 }}
            transition={{ type: 'spring', stiffness: 340, damping: 28 }}
            onClick={(e) => e.stopPropagation()}
            className={`bg-white rounded-3xl w-full ${width} shadow-elev border border-ink-200 overflow-hidden`}
          >
            <div className="relative flex items-center gap-3 px-6 py-5 border-b border-ink-100 bg-gradient-to-b from-emerald-50/70 to-white">
              {Icon && <div className="w-10 h-10 shrink-0 rounded-2xl bg-gradient-to-br from-emerald-500 to-emerald-700 text-white flex items-center justify-center shadow-md"><Icon className="w-5 h-5" /></div>}
              <div className="min-w-0 flex-1">
                <h3 className="font-semibold text-ink-900 truncate">{title}</h3>
                {subtitle && <p className="text-xs text-ink-500 mt-0.5">{subtitle}</p>}
              </div>
              <button onClick={onClose} aria-label="Close" className="p-2 rounded-xl text-ink-500 hover:bg-ink-100 hover:text-ink-900 transition-colors"><X className="w-4 h-4" /></button>
            </div>
            <div className="p-6 max-h-[68vh] overflow-y-auto scrollbar-thin">{children}</div>
            {footer && <div className="px-6 py-4 border-t border-ink-100 bg-ink-50/60 flex justify-end gap-2">{footer}</div>}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
