import { motion } from 'framer-motion';
import { Check, X, type LucideIcon } from 'lucide-react';

export interface Step { key: string; label: string; icon?: LucideIcon }

/** Horizontal progress stepper. `current` is the index of the active step (-1 = none). */
export function Stepper({
  steps, current, failed = false, completed = false,
}: { steps: Step[]; current: number; failed?: boolean; completed?: boolean }) {
  return (
    <div className="overflow-x-auto no-scrollbar -mx-1 px-1">
      <ol className="flex items-start min-w-max">
        {steps.map((s, i) => {
          const done = completed || i < current;
          const active = !completed && i === current;
          const bad = failed && active;
          const Icon = s.icon;
          return (
            <li key={s.key} className="flex-1 min-w-[92px] flex flex-col items-center relative">
              {i > 0 && (
                <div className="absolute top-[18px] right-1/2 w-full h-[3px] rounded-full bg-ink-200 overflow-hidden -z-0">
                  <motion.div className="h-full bg-gradient-to-r from-emerald-500 to-emerald-600" initial={{ width: 0 }}
                    animate={{ width: done || active ? '100%' : '0%' }} transition={{ duration: 0.7, delay: i * 0.08 }} />
                </div>
              )}
              <div className="relative z-10">
                {active && !bad && <span className="absolute inset-0 rounded-full bg-emerald-400/50 animate-ping-slow" />}
                <motion.div initial={{ scale: 0.6, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} transition={{ delay: i * 0.06, type: 'spring', stiffness: 300, damping: 20 }}
                  className={`relative w-9 h-9 rounded-full flex items-center justify-center border-2 transition-colors ${
                    bad ? 'bg-red-600 border-red-600 text-white'
                      : done ? 'bg-emerald-600 border-emerald-600 text-white'
                      : active ? 'bg-white border-emerald-600 text-emerald-700 shadow-[0_0_0_4px_rgba(16,185,129,0.15)]'
                      : 'bg-white border-ink-200 text-ink-400'}`}>
                  {bad ? <X className="w-4 h-4" /> : done ? <Check className="w-4 h-4" /> : Icon ? <Icon className="w-4 h-4" /> : <span className="text-xs font-semibold">{i + 1}</span>}
                </motion.div>
              </div>
              <div className={`mt-2 px-1 text-center text-[11.5px] leading-tight ${active ? 'font-semibold text-ink-900' : done ? 'text-ink-700' : 'text-ink-400'}`}>{s.label}</div>
            </li>
          );
        })}
      </ol>
    </div>
  );
}
