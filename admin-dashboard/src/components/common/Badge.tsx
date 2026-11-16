type Tone = 'emerald' | 'gold' | 'red' | 'amber' | 'slate' | 'blue';
const tones: Record<Tone, { box: string; dot: string }> = {
  emerald: { box: 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200', dot: 'bg-emerald-500' },
  gold: { box: 'bg-gold-50 text-gold-700 ring-1 ring-gold-200', dot: 'bg-gold-500' },
  red: { box: 'bg-red-50 text-red-700 ring-1 ring-red-200', dot: 'bg-red-500' },
  amber: { box: 'bg-amber-50 text-amber-700 ring-1 ring-amber-200', dot: 'bg-amber-500' },
  slate: { box: 'bg-ink-100 text-ink-700 ring-1 ring-ink-200', dot: 'bg-ink-400' },
  blue: { box: 'bg-sky-50 text-sky-700 ring-1 ring-sky-200', dot: 'bg-sky-500' },
};

export function Badge({
  tone = 'slate', children, className = '', dot, pulse,
}: { tone?: Tone; children: React.ReactNode; className?: string; dot?: boolean; pulse?: boolean }) {
  const t = tones[tone];
  return (
    <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium whitespace-nowrap ${t.box} ${className}`}>
      {(dot || pulse) && (
        <span className="relative flex w-1.5 h-1.5">
          {pulse && <span className={`absolute inset-0 rounded-full ${t.dot} animate-ping-slow`} />}
          <span className={`relative w-1.5 h-1.5 rounded-full ${t.dot}`} />
        </span>
      )}
      {children}
    </span>
  );
}
