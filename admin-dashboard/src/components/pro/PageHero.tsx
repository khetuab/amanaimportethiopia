import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowLeft, type LucideIcon } from 'lucide-react';
import { HeroArt, type ArtKind } from './Art';
import { ease } from './motion';

export interface HeroStat { label: string; value: React.ReactNode; icon?: LucideIcon }

interface Props {
  eyebrow?: string;
  eyebrowIcon?: LucideIcon;
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  art?: ArtKind | React.ReactNode;
  back?: { to: string; label: string };
  meta?: React.ReactNode;
  actions?: React.ReactNode;
  stats?: HeroStat[];
}

/** Animated emerald banner that opens every page. */
export function PageHero({ eyebrow, eyebrowIcon: EyebrowIcon, title, subtitle, art, back, meta, actions, stats }: Props) {
  return (
    <motion.section
      initial={{ opacity: 0, y: 14, scale: 0.99 }} animate={{ opacity: 1, y: 0, scale: 1 }} transition={{ duration: 0.6, ease }}
      className="relative overflow-hidden rounded-[28px] bg-emerald-950 text-white shadow-elev"
    >
      {/* aurora */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute -top-32 -left-24 w-[26rem] h-[26rem] rounded-full bg-emerald-600/40 blur-3xl animate-aurora" />
        <div className="absolute -bottom-40 right-0 w-[30rem] h-[30rem] rounded-full bg-teal-500/25 blur-3xl animate-aurora-rev" />
        <div className="absolute top-0 right-1/3 w-64 h-64 rounded-full bg-gold-400/10 blur-3xl animate-aurora" />
        <div className="absolute inset-0 bg-grid-light mask-fade-l opacity-70" />
      </div>

      <div className="relative grid md:grid-cols-[minmax(0,1fr)_auto] gap-6 items-center p-6 sm:p-8 lg:p-10">
        <div className="min-w-0">
          {back && (
            <Link to={back.to} className="group flex w-fit items-center gap-1.5 text-sm text-emerald-200/90 hover:text-white transition-colors mb-4">
              <ArrowLeft className="w-4 h-4 transition-transform group-hover:-translate-x-1" /> {back.label}
            </Link>
          )}
          {eyebrow && (
            <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.15, duration: 0.5 }}
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 border border-white/15 text-emerald-100 text-xs font-medium tracking-wide mb-4">
              {EyebrowIcon ? <EyebrowIcon className="w-3.5 h-3.5 text-gold-300" /> : <span className="relative flex w-2 h-2"><span className="absolute inset-0 rounded-full bg-emerald-300 animate-ping-slow" /><span className="relative w-2 h-2 rounded-full bg-emerald-300" /></span>}
              {eyebrow}
            </motion.div>
          )}
          <motion.h1 initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1, duration: 0.6, ease }}
            className="font-display text-3xl sm:text-4xl lg:text-[2.6rem] leading-tight text-balance break-words">
            {title}
          </motion.h1>
          {subtitle && (
            <motion.p initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.22, duration: 0.6, ease }}
              className="mt-3 text-emerald-100/80 max-w-2xl text-[15px] leading-relaxed">
              {subtitle}
            </motion.p>
          )}
          {meta && <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.3 }} className="mt-4 flex flex-wrap items-center gap-2 text-sm text-emerald-100/80">{meta}</motion.div>}
          {actions && (
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.38, duration: 0.5, ease }} className="mt-6 flex flex-wrap gap-2.5">
              {actions}
            </motion.div>
          )}
        </div>
        {art && (
          <motion.div initial={{ opacity: 0, scale: 0.85, rotate: -4 }} animate={{ opacity: 1, scale: 1, rotate: 0 }} transition={{ delay: 0.2, duration: 0.8, ease }}
            className="hidden md:flex items-center justify-center">
            {typeof art === 'string' ? <HeroArt kind={art as ArtKind} /> : art}
          </motion.div>
        )}
      </div>

      {stats && stats.length > 0 && (
        <div className="relative border-t border-white/10 bg-black/15 backdrop-blur-sm">
          <div className="grid grid-cols-2 md:grid-flow-col md:auto-cols-fr divide-x divide-white/10">
            {stats.map((s, i) => (
              <motion.div key={s.label} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 + i * 0.07, duration: 0.5 }}
                className="px-5 sm:px-7 py-4 flex items-center gap-3 min-w-0">
                {s.icon && <div className="w-9 h-9 shrink-0 rounded-xl bg-white/10 flex items-center justify-center text-emerald-200"><s.icon className="w-[18px] h-[18px]" /></div>}
                <div className="min-w-0">
                  <div className="text-lg font-semibold leading-tight truncate">{s.value}</div>
                  <div className="text-[11px] uppercase tracking-wider text-emerald-200/70 truncate">{s.label}</div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      )}
    </motion.section>
  );
}
