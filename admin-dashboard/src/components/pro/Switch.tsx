import { motion } from 'framer-motion';

export function Switch({
  checked, onChange, disabled, label,
}: { checked: boolean; onChange: (v: boolean) => void; disabled?: boolean; label?: string }) {
  return (
    <button
      type="button" role="switch" aria-checked={checked} aria-label={label} disabled={disabled}
      onClick={() => onChange(!checked)}
      className={`relative w-11 h-6 rounded-full transition-colors duration-300 disabled:opacity-50 ${checked ? 'bg-emerald-600' : 'bg-ink-300'}`}
    >
      <motion.span
        layout transition={{ type: 'spring', stiffness: 500, damping: 32 }}
        className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow ${checked ? 'right-0.5' : 'left-0.5'}`}
      />
    </button>
  );
}
