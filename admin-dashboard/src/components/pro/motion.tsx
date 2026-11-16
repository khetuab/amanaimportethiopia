import { useEffect, useRef, useState } from 'react';
import { animate, motion, useMotionValue, useReducedMotion, type Variants } from 'framer-motion';

export const ease = [0.22, 1, 0.36, 1] as const;

const container = (gap: number, delay: number): Variants => ({
  hidden: {},
  show: { transition: { staggerChildren: gap, delayChildren: delay } },
});
const item: Variants = {
  hidden: { opacity: 0, y: 16 },
  show: { opacity: 1, y: 0, transition: { duration: 0.5, ease } },
};

/** Staggers the entrance of every <StaggerItem> inside it. */
export function Stagger({
  children, className = '', gap = 0.07, delay = 0,
}: { children: React.ReactNode; className?: string; gap?: number; delay?: number }) {
  return (
    <motion.div className={className} variants={container(gap, delay)} initial="hidden" animate="show">
      {children}
    </motion.div>
  );
}

export function StaggerItem({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  return <motion.div className={className} variants={item}>{children}</motion.div>;
}

/** Fades + lifts its children when scrolled into view. */
export function Reveal({
  children, className = '', delay = 0, y = 18,
}: { children: React.ReactNode; className?: string; delay?: number; y?: number }) {
  return (
    <motion.div
      className={className}
      initial={{ opacity: 0, y }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, amount: 0.15 }}
      transition={{ duration: 0.55, ease, delay }}
    >
      {children}
    </motion.div>
  );
}

/** Animated number. `format` renders the interpolated value. */
export function CountUp({
  value, format = (n: number) => Math.round(n).toLocaleString(), duration = 1.1, className = '',
}: { value: number; format?: (n: number) => string; duration?: number; className?: string }) {
  const reduce = useReducedMotion();
  const mv = useMotionValue(0);
  const fmt = useRef(format);
  fmt.current = format;
  const [text, setText] = useState(() => format(reduce ? value : 0));

  useEffect(() => {
    if (reduce) { setText(fmt.current(value)); return; }
    const unsub = mv.on('change', (v) => setText(fmt.current(v)));
    const controls = animate(mv, value, { duration, ease });
    return () => { controls.stop(); unsub(); };
  }, [value, duration, reduce, mv]);

  return <span className={`tabular-nums ${className}`}>{text}</span>;
}
