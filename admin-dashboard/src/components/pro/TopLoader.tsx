import { useIsFetching, useIsMutating } from '@tanstack/react-query';
import { motion } from 'framer-motion';

/** Slim progress bar at the very top that runs whenever data is loading or saving. */
export function TopLoader() {
  const busy = useIsFetching() + useIsMutating() > 0;
  return (
    <div className="fixed top-0 inset-x-0 z-[60] h-[3px] pointer-events-none">
      <motion.div
        className="h-full bg-gradient-to-r from-emerald-400 via-emerald-500 to-gold-400 shadow-[0_0_10px_rgba(16,185,129,0.8)]"
        initial={false}
        animate={busy ? { width: ['0%', '65%', '88%'], opacity: 1 } : { width: '100%', opacity: 0 }}
        transition={busy ? { duration: 2.2, ease: 'easeOut' } : { duration: 0.35 }}
      />
    </div>
  );
}
