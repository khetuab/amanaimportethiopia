import { forwardRef, SelectHTMLAttributes } from 'react';
import { ChevronDown } from 'lucide-react';
interface Props extends SelectHTMLAttributes<HTMLSelectElement> { label?: string; error?: string }

export const Select = forwardRef<HTMLSelectElement, Props>(
  ({ label, error, className = '', children, ...rest }, ref) => (
    <label className="block">
      {label && <span className="block text-sm font-medium text-ink-700 mb-1.5">{label}</span>}
      <span className="relative block">
        <select
          ref={ref}
          className={`w-full h-11 pl-3.5 pr-10 appearance-none rounded-2xl border bg-white text-ink-900 transition-all focus:outline-none focus:ring-4 focus:ring-emerald-500/15 focus:border-emerald-500 ${error ? 'border-red-400' : 'border-ink-200'} ${className}`}
          {...rest}
        >{children}</select>
        <ChevronDown className="pointer-events-none absolute right-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-400" />
      </span>
      {error && <span className="block text-xs text-red-600 mt-1.5">{error}</span>}
    </label>
  ),
);
Select.displayName = 'Select';
