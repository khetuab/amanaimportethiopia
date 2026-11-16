import { motion } from 'framer-motion';

export function ProgressRing({
  value, size = 150, stroke = 12, label, sub, light = false,
}: { value: number; size?: number; stroke?: number; label?: React.ReactNode; sub?: string; light?: boolean }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const pct = Math.max(0, Math.min(100, value));
  return (
    <div className="relative" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <defs>
          <linearGradient id="ring-grad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#6ee7b7" /><stop offset="1" stopColor="#10b981" />
          </linearGradient>
        </defs>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={light ? 'rgba(255,255,255,0.14)' : '#e2e8f0'} strokeWidth={stroke} />
        <motion.circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="url(#ring-grad)" strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={c} initial={{ strokeDashoffset: c }} animate={{ strokeDashoffset: c * (1 - pct / 100) }}
          transition={{ duration: 1.4, ease: [0.22, 1, 0.36, 1] }} />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
        <div className={`text-3xl font-semibold ${light ? 'text-white' : 'text-emerald-950'}`}>{label ?? `${Math.round(pct)}%`}</div>
        {sub && <div className={`text-[11px] uppercase tracking-wider ${light ? 'text-emerald-200/80' : 'text-ink-500'}`}>{sub}</div>}
      </div>
    </div>
  );
}
