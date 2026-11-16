import { useId } from 'react';
import { motion } from 'framer-motion';
import { LayoutGrid, Rows3, Search, X, type LucideIcon } from 'lucide-react';

export function FilterBar({ children }: { children: React.ReactNode }) {
  return <div className="flex flex-col lg:flex-row lg:items-center gap-3">{children}</div>;
}

export function SearchField({
  value, onChange, placeholder = 'Search…', className = '',
}: { value: string; onChange: (v: string) => void; placeholder?: string; className?: string }) {
  return (
    <div className={`group relative flex-1 min-w-[220px] ${className}`}>
      <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-400 group-focus-within:text-emerald-600 transition-colors" />
      <input
        value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder}
        className="w-full h-11 pl-10 pr-9 rounded-2xl bg-white border border-ink-200 text-sm placeholder:text-ink-400 shadow-card transition-all focus:outline-none focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/15"
      />
      {value && (
        <button onClick={() => onChange('')} aria-label="Clear search" className="absolute right-2.5 top-1/2 -translate-y-1/2 p-1 rounded-full text-ink-400 hover:text-ink-700 hover:bg-ink-100">
          <X className="w-3.5 h-3.5" />
        </button>
      )}
    </div>
  );
}

export interface SegOption<T extends string> { value: T; label: string; icon?: LucideIcon; count?: number }

export function SegmentedFilter<T extends string>({
  options, value, onChange,
}: { options: SegOption<T>[]; value: T; onChange: (v: T) => void }) {
  const id = useId();
  return (
    <div className="max-w-full overflow-x-auto no-scrollbar">
      <div className="inline-flex gap-1 p-1 rounded-2xl bg-white border border-ink-200 shadow-card">
        {options.map((o) => {
          const active = o.value === value;
          return (
            <button key={o.value || 'all'} onClick={() => onChange(o.value)}
              className={`relative whitespace-nowrap px-3.5 h-9 rounded-xl text-sm font-medium inline-flex items-center gap-1.5 transition-colors ${active ? 'text-white' : 'text-ink-600 hover:text-ink-900 hover:bg-ink-50'}`}>
              {active && (
                <motion.span layoutId={`seg-${id}`} className="absolute inset-0 rounded-xl bg-gradient-to-br from-emerald-600 to-emerald-800 shadow-[0_6px_16px_-6px_rgba(4,120,87,0.7)]"
                  transition={{ type: 'spring', stiffness: 420, damping: 34 }} />
              )}
              <span className="relative inline-flex items-center gap-1.5">
                {o.icon && <o.icon className="w-3.5 h-3.5" />}
                {o.label}
                {o.count != null && (
                  <span className={`text-[11px] px-1.5 rounded-full ${active ? 'bg-white/20' : 'bg-ink-100 text-ink-500'}`}>{o.count}</span>
                )}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

export function ViewToggle({ value, onChange }: { value: 'cards' | 'table'; onChange: (v: 'cards' | 'table') => void }) {
  const id = useId();
  const items = [{ v: 'cards' as const, Icon: LayoutGrid, label: 'Cards' }, { v: 'table' as const, Icon: Rows3, label: 'Table' }];
  return (
    <div className="inline-flex p-1 rounded-2xl bg-white border border-ink-200 shadow-card">
      {items.map(({ v, Icon, label }) => (
        <button key={v} onClick={() => onChange(v)} aria-label={`${label} view`} aria-pressed={value === v}
          className={`relative w-10 h-9 rounded-xl flex items-center justify-center transition-colors ${value === v ? 'text-emerald-800' : 'text-ink-400 hover:text-ink-700'}`}>
          {value === v && <motion.span layoutId={`vt-${id}`} className="absolute inset-0 rounded-xl bg-emerald-50 ring-1 ring-emerald-200" transition={{ type: 'spring', stiffness: 420, damping: 34 }} />}
          <Icon className="relative w-4 h-4" />
        </button>
      ))}
    </div>
  );
}
