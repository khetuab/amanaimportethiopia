import { forwardRef, InputHTMLAttributes, TextareaHTMLAttributes, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { Eye, EyeOff } from 'lucide-react';

interface Props extends InputHTMLAttributes<HTMLInputElement> {
  label?: string; error?: string; hint?: string; icon?: React.ReactNode;
}

const field =
  'w-full rounded-2xl border bg-white text-ink-900 placeholder:text-ink-400 transition-all duration-200 focus:outline-none focus:ring-4 focus:ring-emerald-500/15 focus:border-emerald-500';

export const Input = forwardRef<HTMLInputElement, Props>(
  ({ label, error, hint, icon, className = '', type, ...rest }, ref) => {
    const [show, setShow] = useState(false);
    const isPwd = type === 'password';
    return (
      <label className="block">
        {label && <span className="block text-sm font-medium text-ink-700 mb-1.5">{label}</span>}
        <span className={`relative block ${error ? 'animate-shake' : ''}`} key={error ?? 'ok'}>
          {icon && <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-400 [&>svg]:w-4 [&>svg]:h-4 peer-focus:text-emerald-600">{icon}</span>}
          <input
            ref={ref}
            type={isPwd && show ? 'text' : type}
            className={`${field} h-11 ${icon ? 'pl-10' : 'px-3.5'} ${isPwd ? 'pr-11' : 'pr-3.5'} ${error ? 'border-red-400 focus:border-red-500 focus:ring-red-500/15' : 'border-ink-200'} ${className}`}
            {...rest}
          />
          {isPwd && (
            <button type="button" tabIndex={-1} onClick={() => setShow((s) => !s)} aria-label={show ? 'Hide password' : 'Show password'}
              className="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg flex items-center justify-center text-ink-400 hover:text-ink-700 hover:bg-ink-100">
              <AnimatePresence mode="wait" initial={false}>
                <motion.span key={show ? 'off' : 'on'} initial={{ rotate: -80, opacity: 0, scale: 0.6 }} animate={{ rotate: 0, opacity: 1, scale: 1 }} exit={{ rotate: 80, opacity: 0, scale: 0.6 }} transition={{ duration: 0.15 }}>
                  {show ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </motion.span>
              </AnimatePresence>
            </button>
          )}
        </span>
        {error && <span className="block text-xs text-red-600 mt-1.5">{error}</span>}
        {hint && !error && <span className="block text-xs text-ink-500 mt-1.5">{hint}</span>}
      </label>
    );
  },
);
Input.displayName = 'Input';

interface AreaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> { label?: string; error?: string; hint?: string }

export const Textarea = forwardRef<HTMLTextAreaElement, AreaProps>(
  ({ label, error, hint, className = '', ...rest }, ref) => (
    <label className="block">
      {label && <span className="block text-sm font-medium text-ink-700 mb-1.5">{label}</span>}
      <textarea
        ref={ref}
        className={`${field} px-3.5 py-3 text-sm leading-relaxed ${error ? 'border-red-400' : 'border-ink-200'} ${className}`}
        {...rest}
      />
      {error && <span className="block text-xs text-red-600 mt-1.5">{error}</span>}
      {hint && !error && <span className="block text-xs text-ink-500 mt-1.5">{hint}</span>}
    </label>
  ),
);
Textarea.displayName = 'Textarea';
