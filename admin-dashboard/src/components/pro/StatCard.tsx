import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import type { LucideIcon } from 'lucide-react';
import { CountUp } from './motion';

type Tone = 'emerald' | 'gold' | 'red' | 'blue' | 'violet';
const tones: Record<Tone, { chip: string; blob: string; bar: string }> = {
  emerald: { chip: 'from-emerald-500 to-emerald-700 text-white', blob: 'bg-emerald-400/20', bar: 'from-emerald-400 to-emerald-600' },
  gold: { chip: 'from-amber-400 to-amber-600 text-white', blob: 'bg-amber-300/25', bar: 'from-amber-300 to-amber-500' },
  red: { chip: 'from-rose-500 to-red-600 text-white', blob: 'bg-red-400/20', bar: 'from-rose-400 to-red-500' },
  blue: { chip: 'from-sky-500 to-sky-700 text-white', blob: 'bg-sky-400/20', bar: 'from-sky-400 to-sky-600' },
  violet: { chip: 'from-violet-500 to-violet-700 text-white', blob: 'bg-violet-400/20', bar: 'from-violet-400 to-violet-600' },
};

interface Props {
  icon: LucideIcon; label: string; value: number | string; sub?: React.ReactNode;
  tone?: Tone; format?: (n: number) => string; to?: string; pulse?: boolean;
}

export function StatCard({ icon: Icon, label, value, sub, tone = 'emerald', format, to, pulse }: Props) {
  const t = tones[tone];
  const body = (
    <motion.div whileHover={{ y: -4 }} transition={{ type: 'spring', stiffness: 300, damping: 22 }}
      className="relative h-full overflow-hidden p-5 rounded-3xl bg-white border border-ink-200/70 shadow-card hover:shadow-elev/0 hover:shadow-[0_18px_40px_-18px_rgba(2,44,34,0.35)] transition-shadow">
      <div className={`absolute -top-10 -right-10 w-32 h-32 rounded-full blur-2xl ${t.blob}`} />
      <div className="relative flex items-start justify-between">
        <div className={`w-11 h-11 rounded-2xl bg-gradient-to-br ${t.chip} flex items-center justify-center shadow-lg`}>
          <Icon className="w-5 h-5" />
        </div>
        {pulse && <span className="relative flex w-2.5 h-2.5"><span className="absolute inset-0 rounded-full bg-red-400 animate-ping-slow" /><span className="relative w-2.5 h-2.5 rounded-full bg-red-500" /></span>}
      </div>
      <div className="relative mt-5 text-[1.7rem] leading-none font-semibold text-emerald-950">
        {typeof value === 'number' ? <CountUp value={value} format={format} /> : value}
      </div>
      <div className="relative text-sm text-ink-500 mt-1.5">{label}</div>
      {sub && <div className="relative text-xs text-ink-400 mt-1">{sub}</div>}
      <div className={`absolute bottom-0 left-0 h-1 w-full bg-gradient-to-r ${t.bar} opacity-70 origin-left`} />
    </motion.div>
  );
  return to ? <Link to={to} className="block h-full rounded-3xl focus-visible:outline-emerald-500">{body}</Link> : body;
}
