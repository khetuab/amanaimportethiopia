import type { LucideIcon } from 'lucide-react';

export function InfoList({ children }: { children: React.ReactNode }) {
  return <div className="divide-y divide-ink-100">{children}</div>;
}

export function InfoRow({
  label, value, icon: Icon, mono, bold,
}: { label: string; value: React.ReactNode; icon?: LucideIcon; mono?: boolean; bold?: boolean }) {
  return (
    <div className="flex items-start justify-between gap-6 py-3 text-sm group">
      <span className="flex items-center gap-2 text-ink-500 shrink-0">
        {Icon && <Icon className="w-4 h-4 text-ink-400 group-hover:text-emerald-600 transition-colors" />}
        {label}
      </span>
      <span className={`text-right text-ink-900 min-w-0 break-words ${mono ? 'font-mono text-xs' : ''} ${bold ? 'font-semibold' : ''}`}>{value}</span>
    </div>
  );
}
