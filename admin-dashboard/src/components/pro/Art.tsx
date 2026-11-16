import { motion } from 'framer-motion';
import type { LucideIcon } from 'lucide-react';
import {
  BadgeCheck, CreditCard, Package, Scale, Tags, ClipboardList, FileSignature,
  Percent, Landmark, ScrollText, ShieldCheck, Users, ShieldAlert, Truck, FileText,
  Banknote, Globe2, Sparkles, Search, Receipt, Wallet, Lock, Store, UserCheck, AlertTriangle,
} from 'lucide-react';

/* ------------------------------------------------------------------ */
/*  Orbit art: glowing core + satellites orbiting it                   */
/* ------------------------------------------------------------------ */
export function OrbitArt({
  icon: Icon, satellites = [], size = 200,
}: { icon: LucideIcon; satellites?: LucideIcon[]; size?: number }) {
  const r = size * 0.42;
  const spin = { duration: 34, repeat: Infinity, ease: 'linear' as const };
  return (
    <div className="relative shrink-0" style={{ width: size, height: size }} aria-hidden>
      <div className="absolute inset-0 rounded-full bg-emerald-400/15 blur-2xl" />
      <div className="absolute inset-0 rounded-full border border-white/15" />
      <div className="absolute inset-[13%] rounded-full border border-dashed border-white/25 animate-spin-slow" />
      <div className="absolute inset-[26%] rounded-full border border-white/10 animate-spin-slow-rev" />
      <motion.div className="absolute inset-0" animate={{ rotate: 360 }} transition={spin}>
        {satellites.map((S, i) => {
          const a = (i / Math.max(satellites.length, 1)) * Math.PI * 2 - Math.PI / 2;
          return (
            <div key={i} className="absolute" style={{ left: size / 2 + Math.cos(a) * r - 19, top: size / 2 + Math.sin(a) * r - 19 }}>
              <motion.div
                animate={{ rotate: -360 }} transition={spin}
                className="w-[38px] h-[38px] rounded-full bg-white/12 border border-white/25 backdrop-blur-sm flex items-center justify-center text-white shadow-lg"
              >
                <S className="w-[18px] h-[18px]" />
              </motion.div>
            </div>
          );
        })}
      </motion.div>
      <motion.div
        animate={{ scale: [1, 1.07, 1] }} transition={{ duration: 3.6, repeat: Infinity, ease: 'easeInOut' }}
        className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[34%] h-[34%] rounded-[28%] bg-gradient-to-br from-emerald-300 to-emerald-600 shadow-[0_0_44px_rgba(52,211,153,0.55)] flex items-center justify-center text-emerald-950"
      >
        <Icon className="w-1/2 h-1/2" />
      </motion.div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/*  Verify: shield with a drawn check + fanned documents               */
/* ------------------------------------------------------------------ */
function VerifyArt() {
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <defs>
        <linearGradient id="va-shield" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#6ee7b7" /><stop offset="1" stopColor="#059669" />
        </linearGradient>
      </defs>
      {[-14, 0, 14].map((deg, i) => (
        <motion.g key={i} style={{ originX: 0.5, originY: 1 }}
          initial={{ rotate: 0, opacity: 0 }} animate={{ rotate: deg, opacity: 1 }}
          transition={{ delay: 0.2 + i * 0.12, type: 'spring', stiffness: 120, damping: 14 }}>
          <rect x="72" y="50" width="96" height="120" rx="12" fill="white" fillOpacity={0.12 + i * 0.05} stroke="white" strokeOpacity="0.3" />
          <rect x="86" y="68" width="48" height="6" rx="3" fill="white" fillOpacity="0.5" />
          <rect x="86" y="82" width="68" height="5" rx="2.5" fill="white" fillOpacity="0.3" />
          <rect x="86" y="94" width="56" height="5" rx="2.5" fill="white" fillOpacity="0.3" />
        </motion.g>
      ))}
      <motion.g animate={{ y: [0, -6, 0] }} transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}>
        <path d="M120 24 L164 40 V92 C164 120 146 140 120 150 C94 140 76 120 76 92 V40 Z" fill="url(#va-shield)" stroke="white" strokeOpacity="0.5" strokeWidth="2" />
        <motion.path d="M100 88 L116 104 L142 74" fill="none" stroke="#022c22" strokeWidth="9" strokeLinecap="round" strokeLinejoin="round"
          initial={{ pathLength: 0 }} animate={{ pathLength: [0, 1, 1, 0] }}
          transition={{ duration: 3.4, repeat: Infinity, times: [0, 0.35, 0.8, 1], ease: 'easeInOut' }} />
      </motion.g>
      {[[40, 60], [204, 52], [196, 140], [34, 128]].map(([x, y], i) => (
        <motion.circle key={i} cx={x} cy={y} r="3" fill="#a7f3d0"
          animate={{ opacity: [0.2, 1, 0.2], scale: [0.8, 1.4, 0.8] }} transition={{ duration: 2.4, repeat: Infinity, delay: i * 0.5 }} />
      ))}
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Payments: receipt that gets stamped, coins floating                */
/* ------------------------------------------------------------------ */
function ReceiptArt() {
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <motion.g animate={{ y: [0, -5, 0] }} transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}>
        <path d="M70 20 H170 V176 L158 168 L146 176 L134 168 L122 176 L110 168 L98 176 L86 168 L70 176 Z" fill="white" fillOpacity="0.14" stroke="white" strokeOpacity="0.35" strokeWidth="1.5" />
        <rect x="86" y="40" width="44" height="7" rx="3.5" fill="white" fillOpacity="0.6" />
        {[62, 78, 94].map((y, i) => (
          <g key={y}>
            <rect x="86" y={y} width={52 + i * 6} height="5" rx="2.5" fill="white" fillOpacity="0.3" />
            <rect x="146" y={y} width="14" height="5" rx="2.5" fill="white" fillOpacity="0.45" />
          </g>
        ))}
        <rect x="86" y="116" width="74" height="1.5" fill="white" fillOpacity="0.3" />
        <rect x="86" y="128" width="30" height="8" rx="4" fill="#6ee7b7" fillOpacity="0.9" />
        <rect x="132" y="128" width="28" height="8" rx="4" fill="white" fillOpacity="0.55" />
        <motion.g style={{ originX: 0.5, originY: 0.5 }}
          animate={{ scale: [2.2, 1, 1, 1], opacity: [0, 1, 1, 0], rotate: [-18, -12, -12, -12] }}
          transition={{ duration: 3.6, repeat: Infinity, times: [0, 0.2, 0.8, 1], ease: 'easeOut' }}>
          <circle cx="140" cy="120" r="24" fill="none" stroke="#34d399" strokeWidth="4" />
          <path d="M128 120 L137 129 L153 111" fill="none" stroke="#34d399" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" />
        </motion.g>
      </motion.g>
      {[[190, 56, 0], [206, 120, 0.8], [48, 140, 1.4]].map(([x, y, d], i) => (
        <motion.g key={i} animate={{ y: [0, -10, 0] }} transition={{ duration: 3.4, repeat: Infinity, delay: d, ease: 'easeInOut' }}>
          <circle cx={x} cy={y} r="13" fill="#fbbf24" stroke="#fde68a" strokeWidth="2" />
          <text x={x} y={y + 4.5} textAnchor="middle" fontSize="12" fontWeight="700" fill="#78350f">B</text>
        </motion.g>
      ))}
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Orders: truck driving a route between port and home                */
/* ------------------------------------------------------------------ */
function OrdersArt() {
  return (
    <svg viewBox="0 0 260 200" className="w-[260px] h-[200px]" aria-hidden>
      <motion.path id="orders-route" d="M36 150 C 70 40, 150 190, 224 62" fill="none" stroke="white" strokeOpacity="0.4" strokeWidth="2.5" strokeDasharray="3 9" strokeLinecap="round"
        animate={{ strokeDashoffset: [0, -24] }} transition={{ duration: 1.4, repeat: Infinity, ease: 'linear' }} />
      <circle cx="36" cy="150" r="17" fill="white" fillOpacity="0.15" stroke="white" strokeOpacity="0.4" />
      <circle cx="224" cy="62" r="17" fill="white" fillOpacity="0.15" stroke="white" strokeOpacity="0.4" />
      <g transform="translate(224 62)"><path d="M-7 1 L0 -6 L7 1 V8 H-7 Z" fill="#6ee7b7" /></g>
      <g transform="translate(36 150)"><path d="M-9 3 H9 L6 9 H-6 Z" fill="#6ee7b7" /><rect x="-2" y="-8" width="4" height="9" fill="#6ee7b7" /><path d="M-2 -8 L8 -3 H-2 Z" fill="#6ee7b7" /></g>
      <g>
        <circle r="15" fill="#34d399">
          <animateMotion dur="6s" repeatCount="indefinite" rotate="0" keyPoints="0;1;1" keyTimes="0;0.85;1" calcMode="spline" keySplines="0.45 0 0.55 1;0 0 1 1"><mpath href="#orders-route" /></animateMotion>
        </circle>
        <g>
          <animateMotion dur="6s" repeatCount="indefinite" rotate="0" keyPoints="0;1;1" keyTimes="0;0.85;1" calcMode="spline" keySplines="0.45 0 0.55 1;0 0 1 1"><mpath href="#orders-route" /></animateMotion>
          <g transform="translate(-8 -6) scale(.67)" fill="#022c22"><path d="M1 3h13v11H1z" /><path d="M14 7h5l3 4v3h-8z" /><circle cx="6" cy="16" r="2.4" /><circle cx="18" cy="16" r="2.4" /></g>
        </g>
      </g>
      {[[96, 32], [160, 24], [60, 96]].map(([x, y], i) => (
        <motion.rect key={i} x={x} y={y} width="16" height="16" rx="4" fill="white" fillOpacity="0.2" stroke="white" strokeOpacity="0.35"
          animate={{ y: [y, y - 8, y], rotate: [0, 8, 0] }} transition={{ duration: 4 + i, repeat: Infinity, ease: 'easeInOut', delay: i * 0.4 }} />
      ))}
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Disputes: balance scale that settles                               */
/* ------------------------------------------------------------------ */
function ScaleArt() {
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <path d="M120 60 V168" stroke="white" strokeOpacity="0.5" strokeWidth="5" strokeLinecap="round" />
      <path d="M86 176 H154" stroke="white" strokeOpacity="0.5" strokeWidth="7" strokeLinecap="round" />
      <motion.g style={{ originX: 0.5, originY: 0 }}
        animate={{ rotate: [-9, 8, -4, 3, 0, 0, -9] }} transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut' }}>
        <path d="M40 60 H200" stroke="#6ee7b7" strokeWidth="6" strokeLinecap="round" />
        {[40, 200].map((x, i) => (
          <motion.g key={x} style={{ originX: 0.5, originY: 0 }}
            animate={{ rotate: [9, -8, 4, -3, 0, 0, 9] }} transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut' }}>
            <path d={`M${x} 60 L${x - 24} 112 M${x} 60 L${x + 24} 112`} stroke="white" strokeOpacity="0.55" strokeWidth="2" />
            <path d={`M${x - 30} 112 H${x + 30} C${x + 28} 130 ${x - 28} 130 ${x - 30} 112 Z`} fill="white" fillOpacity="0.2" stroke="white" strokeOpacity="0.5" strokeWidth="2" />
            <circle cx={x} cy={i === 0 ? 100 : 102} r="8" fill={i === 0 ? '#fbbf24' : '#a7f3d0'} />
          </motion.g>
        ))}
      </motion.g>
      <circle cx="120" cy="60" r="9" fill="#022c22" stroke="#6ee7b7" strokeWidth="3" />
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Ledger: bars rising with a percent coin                            */
/* ------------------------------------------------------------------ */
function LedgerArt() {
  const bars = [48, 80, 64, 104, 128];
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <path d="M30 168 H214" stroke="white" strokeOpacity="0.35" strokeWidth="2" strokeLinecap="round" />
      {bars.map((h, i) => (
        <motion.rect key={i} x={44 + i * 34} width="22" rx="6" fill={i === bars.length - 1 ? '#6ee7b7' : 'white'} fillOpacity={i === bars.length - 1 ? 0.95 : 0.22 + i * 0.04}
          initial={{ height: 0, y: 168 }} animate={{ height: [0, h, h, 0], y: [168, 168 - h, 168 - h, 168] }}
          transition={{ duration: 5, repeat: Infinity, times: [0, 0.35, 0.85, 1], delay: i * 0.12, ease: 'easeOut' }} />
      ))}
      <motion.g animate={{ y: [0, -9, 0], rotate: [-6, 6, -6] }} transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }} style={{ originX: 0.5, originY: 0.5 }}>
        <circle cx="186" cy="52" r="26" fill="#fbbf24" stroke="#fde68a" strokeWidth="3" />
        <text x="186" y="62" textAnchor="middle" fontSize="28" fontWeight="800" fill="#78350f">%</text>
      </motion.g>
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Audit: log lines being scanned                                     */
/* ------------------------------------------------------------------ */
function AuditArt() {
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <rect x="40" y="24" width="160" height="152" rx="16" fill="white" fillOpacity="0.1" stroke="white" strokeOpacity="0.3" />
      {[0, 1, 2, 3, 4].map((i) => (
        <g key={i}>
          <circle cx="62" cy={54 + i * 26} r="5" fill="#6ee7b7" />
          <motion.rect x="76" y={50 + i * 26} height="8" rx="4" fill="white" fillOpacity="0.4"
            initial={{ width: 0 }} animate={{ width: [0, 90 - (i % 3) * 18, 90 - (i % 3) * 18, 0] }}
            transition={{ duration: 5, repeat: Infinity, times: [0, 0.3, 0.85, 1], delay: i * 0.18 }} />
        </g>
      ))}
      <motion.rect x="46" width="148" height="22" rx="8" fill="#34d399" fillOpacity="0.22" stroke="#6ee7b7" strokeOpacity="0.7"
        animate={{ y: [36, 138, 36] }} transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }} />
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Checklist: items ticking one by one                                */
/* ------------------------------------------------------------------ */
function ChecklistArt() {
  return (
    <svg viewBox="0 0 240 200" className="w-[240px] h-[200px]" aria-hidden>
      <rect x="52" y="20" width="136" height="164" rx="18" fill="white" fillOpacity="0.12" stroke="white" strokeOpacity="0.32" />
      <rect x="92" y="12" width="56" height="18" rx="9" fill="#064e3b" stroke="#6ee7b7" strokeOpacity="0.6" />
      {[0, 1, 2, 3].map((i) => (
        <g key={i}>
          <rect x="70" y={52 + i * 32} width="20" height="20" rx="6" fill="none" stroke="white" strokeOpacity="0.5" strokeWidth="2" />
          <motion.path d={`M74 ${62 + i * 32} L80 ${68 + i * 32} L88 ${57 + i * 32}`} fill="none" stroke="#6ee7b7" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round"
            initial={{ pathLength: 0 }} animate={{ pathLength: [0, 0, 1, 1, 0] }}
            transition={{ duration: 6, repeat: Infinity, times: [0, i * 0.14, i * 0.14 + 0.12, 0.9, 1], ease: 'easeOut' }} />
          <rect x="100" y={56 + i * 32} width={60 - (i % 2) * 14} height="7" rx="3.5" fill="white" fillOpacity="0.4" />
          <rect x="100" y={68 + i * 32} width="38" height="5" rx="2.5" fill="white" fillOpacity="0.2" />
        </g>
      ))}
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Trade scene: globe, routes, container ship (login + dashboard)    */
/* ------------------------------------------------------------------ */
export function TradeScene({ className = '' }: { className?: string }) {
  const containers = ['#e5e7eb', '#ffffff', '#9ca3af', '#d1d5db', '#4b5563'];
  return (
    <svg viewBox="0 0 520 380" className={className} aria-hidden preserveAspectRatio="xMidYMid meet">
      <defs>
        <radialGradient id="ts-glow" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stopColor="#ffffff" stopOpacity="0.3" /><stop offset="1" stopColor="#ffffff" stopOpacity="0" />
        </radialGradient>
        <path id="ts-r1" d="M70 240 C 140 60, 330 40, 440 120" fill="none" />
        <path id="ts-r2" d="M90 280 C 210 190, 320 230, 460 170" fill="none" />
      </defs>
      <circle cx="320" cy="140" r="170" fill="url(#ts-glow)" />
      <g stroke="white" strokeOpacity="0.14" fill="none">
        <circle cx="320" cy="140" r="120" />
        {[0.3, 0.55, 0.8].map((k) => <ellipse key={k} cx="320" cy="140" rx={120 * k} ry="120" />)}
        {[-80, -40, 0, 40, 80].map((dy) => (
          <ellipse key={dy} cx="320" cy={140 + dy} rx={Math.sqrt(120 * 120 - dy * dy)} ry={Math.sqrt(120 * 120 - dy * dy) * 0.16} />
        ))}
      </g>
      {['#ts-r1', '#ts-r2'].map((id, i) => (
        <g key={id}>
          <use href={id} stroke="white" strokeOpacity="0.4" strokeWidth="2" strokeDasharray="2 9" strokeLinecap="round">
            <animate attributeName="stroke-dashoffset" from="0" to="-22" dur="1.4s" repeatCount="indefinite" />
          </use>
          <circle r="11" fill="#d1d5db" fillOpacity="0.3">
            <animateMotion dur={`${7 + i * 2}s`} repeatCount="indefinite" begin={`${i * 1.2}s`}><mpath href={id} /></animateMotion>
          </circle>
          <circle r="4.5" fill="#f3f4f6">
            <animateMotion dur={`${7 + i * 2}s`} repeatCount="indefinite" begin={`${i * 1.2}s`}><mpath href={id} /></animateMotion>
          </circle>
        </g>
      ))}
      {[[70, 240], [440, 120], [90, 280], [460, 170]].map(([x, y], i) => (
        <g key={i}>
          <circle cx={x} cy={y} r="5" fill="#e5e7eb" />
          <circle cx={x} cy={y} r="5" fill="none" stroke="#f3f4f6" className="animate-ping-slow" style={{ transformOrigin: `${x}px ${y}px`, animationDelay: `${i * 0.5}s` }} />
        </g>
      ))}
      {/* ship */}
      <motion.g animate={{ y: [0, 5, 0], rotate: [-0.8, 0.8, -0.8] }} transition={{ duration: 5.5, repeat: Infinity, ease: 'easeInOut' }} style={{ originX: 0.5, originY: 0.7 }}>
        <path d="M70 318 H450 L420 350 H100 Z" fill="#111827" stroke="#d1d5db" strokeOpacity="0.6" strokeWidth="2" />
        <rect x="92" y="262" width="52" height="56" rx="6" fill="#1f2937" stroke="#d1d5db" strokeOpacity="0.5" />
        <rect x="102" y="272" width="32" height="10" rx="3" fill="#e5e7eb" fillOpacity="0.8" />
        <rect x="102" y="288" width="32" height="10" rx="3" fill="#e5e7eb" fillOpacity="0.45" />
        {[0, 1, 2].map((row) =>
          Array.from({ length: 7 - row }).map((_, c) => (
            <motion.rect key={`${row}-${c}`} x={160 + c * 38 + row * 19} y={318 - (row + 1) * 26} width="34" height="23" rx="3" fill={containers[(row * 3 + c) % containers.length]} fillOpacity="0.85"
              initial={{ opacity: 0, y: -16 }} animate={{ opacity: 0.85, y: 0 }} transition={{ delay: 0.4 + (row * 7 + c) * 0.05, duration: 0.5 }} />
          )),
        )}
      </motion.g>
      <g className="animate-wave" style={{ willChange: 'transform' }}>
        <path d="M0 346 q 30 -12 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 t 60 0 V380 H0 Z" fill="#030712" fillOpacity="0.85" />
      </g>
      <g className="animate-wave-rev" style={{ willChange: 'transform' }}>
        <path d="M0 360 q 40 -12 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 t 80 0 V380 H0 Z" fill="#1f2937" fillOpacity="0.9" />
      </g>
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Registry used by <PageHero art="…" />                              */
/* ------------------------------------------------------------------ */
export type ArtKind =
  | 'dashboard' | 'importers' | 'payments' | 'orders' | 'disputes' | 'fraud' | 'categories'
  | 'requests' | 'quotations' | 'rules' | 'reconciliation' | 'audit' | 'legal' | 'users';

export function HeroArt({ kind }: { kind: ArtKind }) {
  switch (kind) {
    case 'importers': return <VerifyArt />;
    case 'payments': return <ReceiptArt />;
    case 'orders': return <OrdersArt />;
    case 'disputes': return <ScaleArt />;
    case 'rules': return <LedgerArt />;
    case 'audit': return <AuditArt />;
    case 'legal': return <ChecklistArt />;
    case 'dashboard': return <OrbitArt icon={Globe2} satellites={[Package, CreditCard, BadgeCheck, Truck, Scale]} />;
    case 'fraud': return <OrbitArt icon={ShieldAlert} satellites={[Search, AlertTriangle, Lock, Users]} />;
    case 'categories': return <OrbitArt icon={Tags} satellites={[Package, Store, Sparkles, Truck, Tags]} />;
    case 'requests': return <OrbitArt icon={ClipboardList} satellites={[FileText, Package, Search, Users]} />;
    case 'quotations': return <OrbitArt icon={FileSignature} satellites={[Banknote, Truck, BadgeCheck, Percent]} />;
    case 'reconciliation': return <OrbitArt icon={Landmark} satellites={[Wallet, Receipt, Banknote, Percent, Scale]} />;
    case 'users': return <OrbitArt icon={UserCheck} satellites={[ShieldCheck, Lock, Users, ScrollText]} />;
  }
}

/* ------------------------------------------------------------------ */
/*  Light-theme art for empty / error states                           */
/* ------------------------------------------------------------------ */
export function StateArt({ icon: Icon, tone = 'emerald' }: { icon: React.ComponentType<{ className?: string }>; tone?: 'emerald' | 'red' }) {
  const t = tone === 'red'
    ? { ring: 'border-red-200', core: 'from-red-50 to-white text-red-600 shadow-red-200/70', dot: 'bg-red-300' }
    : { ring: 'border-emerald-200', core: 'from-emerald-50 to-white text-emerald-700 shadow-emerald-200/70', dot: 'bg-emerald-300' };
  return (
    <div className="relative mx-auto w-40 h-36" aria-hidden>
      <div className={`absolute inset-3 rounded-full border ${t.ring} animate-spin-slow`} style={{ borderStyle: 'dashed' }} />
      <div className={`absolute inset-9 rounded-full border ${t.ring} opacity-60`} />
      {[0, 1, 2, 3].map((i) => (
        <motion.span key={i} className={`absolute w-2 h-2 rounded-full ${t.dot}`}
          style={{ left: `${16 + ((i * 53) % 70)}%`, top: `${10 + ((i * 37) % 70)}%` }}
          animate={{ opacity: [0.15, 1, 0.15], scale: [0.7, 1.3, 0.7] }} transition={{ duration: 2.6, repeat: Infinity, delay: i * 0.6 }} />
      ))}
      <motion.div
        animate={{ y: [0, -7, 0], rotate: tone === 'red' ? [-4, 4, -4] : [-1.5, 1.5, -1.5] }}
        transition={{ duration: 4.5, repeat: Infinity, ease: 'easeInOut' }}
        className={`absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-20 h-20 rounded-3xl bg-gradient-to-br ${t.core} shadow-xl border border-white flex items-center justify-center`}
      >
        <Icon className="w-9 h-9" />
      </motion.div>
    </div>
  );
}
