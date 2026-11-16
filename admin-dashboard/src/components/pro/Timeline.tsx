import { motion } from 'framer-motion';
import { Circle, type LucideIcon } from 'lucide-react';
import { ease } from './motion';

type Tone = 'emerald' | 'amber' | 'red' | 'slate' | 'blue';
const tones: Record<Tone, string> = {
  emerald: 'bg-emerald-600 text-white', amber: 'bg-amber-500 text-white', red: 'bg-red-600 text-white',
  slate: 'bg-ink-400 text-white', blue: 'bg-sky-600 text-white',
};

export interface TimelineItem {
  key?: string; title: React.ReactNode; meta?: React.ReactNode; body?: React.ReactNode; icon?: LucideIcon; tone?: Tone;
}

export function Timeline({ items, pulseLast = true }: { items: TimelineItem[]; pulseLast?: boolean }) {
  return (
    <ol className="relative">
      {items.map((it, i) => {
        const last = i === items.length - 1;
        const Icon = it.icon ?? Circle;
        return (
          <motion.li key={it.key ?? i} className="relative flex gap-4 pb-6 last:pb-0"
            initial={{ opacity: 0, x: -10 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true, amount: 0.4 }}
            transition={{ duration: 0.45, ease, delay: Math.min(i, 6) * 0.05 }}>
            {!last && (
              <motion.span className="absolute left-[15px] top-8 bottom-0 w-px bg-gradient-to-b from-emerald-300 to-ink-200 origin-top"
                initial={{ scaleY: 0 }} whileInView={{ scaleY: 1 }} viewport={{ once: true }} transition={{ duration: 0.6, delay: 0.1 + i * 0.05 }} />
            )}
            <span className="relative shrink-0">
              {last && pulseLast && <span className="absolute inset-0 rounded-full bg-emerald-400/60 animate-ping-slow" />}
              <span className={`relative w-8 h-8 rounded-full flex items-center justify-center shadow-sm ring-4 ring-white ${tones[it.tone ?? 'emerald']}`}>
                <Icon className={it.icon ? 'w-4 h-4' : 'w-2 h-2 fill-current'} />
              </span>
            </span>
            <div className="min-w-0 pt-0.5">
              <div className="text-sm font-medium text-ink-900">{it.title}</div>
              {it.meta && <div className="text-xs text-ink-500 mt-0.5">{it.meta}</div>}
              {it.body && <div className="text-sm text-ink-600 mt-1.5">{it.body}</div>}
            </div>
          </motion.li>
        );
      })}
    </ol>
  );
}
