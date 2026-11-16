import { forwardRef } from 'react';
import { motion, HTMLMotionProps } from 'framer-motion';

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'gold' | 'glass' | 'light' | 'soft';
type Size = 'sm' | 'md' | 'lg';

export interface ButtonProps extends Omit<HTMLMotionProps<'button'>, 'children'> {
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  children?: React.ReactNode;
}

const base =
  'group relative overflow-hidden inline-flex items-center justify-center gap-2 font-medium rounded-xl transition-[background,box-shadow,color,border-color] duration-200 disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 focus-visible:ring-offset-2 select-none';
const variants: Record<Variant, string> = {
  primary: 'bg-gradient-to-br from-emerald-600 to-emerald-800 text-white shadow-[0_8px_20px_-8px_rgba(4,120,87,0.8)] hover:shadow-[0_12px_26px_-8px_rgba(4,120,87,0.9)]',
  secondary: 'bg-white text-emerald-800 border border-emerald-200 hover:bg-emerald-50 hover:border-emerald-300 shadow-card',
  soft: 'bg-emerald-50 text-emerald-800 hover:bg-emerald-100',
  ghost: 'bg-transparent text-ink-700 hover:bg-ink-100',
  danger: 'bg-gradient-to-br from-rose-500 to-red-700 text-white shadow-[0_8px_20px_-8px_rgba(185,28,28,0.7)] hover:shadow-[0_12px_26px_-8px_rgba(185,28,28,0.8)]',
  gold: 'bg-gradient-to-br from-gold-300 to-gold-500 text-ink-900 shadow-[0_8px_20px_-8px_rgba(217,119,6,0.7)] hover:brightness-105',
  glass: 'bg-white/10 text-white border border-white/25 backdrop-blur hover:bg-white/20',
  light: 'bg-white text-emerald-900 hover:bg-emerald-50 shadow-[0_8px_24px_-10px_rgba(0,0,0,0.5)]',
};
const sizes: Record<Size, string> = { sm: 'h-9 px-3.5 text-sm', md: 'h-11 px-5 text-sm', lg: 'h-12 px-6 text-base' };
const shiny: Variant[] = ['primary', 'danger', 'gold'];

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', loading, className = '', children, ...rest }, ref) => (
    <motion.button
      ref={ref}
      whileHover={rest.disabled || loading ? undefined : { y: -1.5 }}
      whileTap={{ scale: 0.97 }}
      transition={{ type: 'spring', stiffness: 500, damping: 28 }}
      className={`${base} ${variants[variant]} ${sizes[size]} ${className}`}
      disabled={loading || rest.disabled}
      {...rest}
    >
      {shiny.includes(variant) && (
        <span className="pointer-events-none absolute inset-y-0 -left-1/2 w-1/3 bg-white/25 blur-sm opacity-0 group-hover:opacity-100 group-hover:animate-sheen" />
      )}
      {loading ? (
        <span className="inline-flex items-center gap-1" aria-label="Loading">
          {[0, 1, 2].map((i) => (
            <motion.span key={i} className="w-1.5 h-1.5 rounded-full bg-current" animate={{ y: [0, -4, 0], opacity: [0.5, 1, 0.5] }} transition={{ duration: 0.7, repeat: Infinity, delay: i * 0.12 }} />
          ))}
        </span>
      ) : null}
      <span className={`relative inline-flex items-center gap-2 ${loading ? 'hidden' : ''}`}>{children}</span>
    </motion.button>
  ),
);
Button.displayName = 'Button';
