import { HTMLAttributes } from 'react';
import type { LucideIcon } from 'lucide-react';

export function Card({
  className = '', children, hover, ...rest
}: HTMLAttributes<HTMLDivElement> & { hover?: boolean }) {
  return (
    <div
      className={`bg-white rounded-3xl border border-ink-200/70 shadow-card ${hover ? 'transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_18px_40px_-18px_rgba(2,44,34,0.3)] hover:border-emerald-200' : ''} ${className}`}
      {...rest}
    >
      {children}
    </div>
  );
}

export function CardHeader({
  title, subtitle, right, icon: Icon,
}: { title: React.ReactNode; subtitle?: React.ReactNode; right?: React.ReactNode; icon?: LucideIcon }) {
  return (
    <div className="flex items-start justify-between gap-4 px-6 pt-5 pb-4 border-b border-ink-100">
      <div className="flex items-center gap-3 min-w-0">
        {Icon && (
          <div className="w-9 h-9 shrink-0 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center"><Icon className="w-[18px] h-[18px]" /></div>
        )}
        <div className="min-w-0">
          <h3 className="text-base font-semibold text-ink-900">{title}</h3>
          {subtitle && <p className="text-sm text-ink-500 mt-0.5">{subtitle}</p>}
        </div>
      </div>
      {right}
    </div>
  );
}

export function CardBody({ className = '', children }: { className?: string; children: React.ReactNode }) {
  return <div className={`p-6 ${className}`}>{children}</div>;
}
