import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { ShieldCheck, ArrowRight, Mail, Lock, BadgeCheck, CreditCard, Scale, AlertCircle } from 'lucide-react';
import { useAuth } from './useAuth';
import { Button } from '@/components/common/Button';
import { Input } from '@/components/common/Input';
import { apiErrorMessage } from '@/api/client';
import { TradeScene } from '@/components/pro/Art';
import { Stagger, StaggerItem } from '@/components/pro/motion';

const features = [
  { icon: BadgeCheck, label: 'Verify importers', cls: 'top-[16%] right-[8%]', delay: 0 },
  { icon: CreditCard, label: 'Review payments', cls: 'top-[44%] left-[6%]', delay: 1.2 },
  { icon: Scale, label: 'Resolve disputes', cls: 'bottom-[1%] right-[6%]', delay: 2.4 },
];

export default function LoginPage() {
  const { login } = useAuth();
  const nav = useNavigate();
  const loc = useLocation() as { state?: { from?: string } };
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [attempt, setAttempt] = useState(0);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null); setLoading(true);
    try {
      await login(identifier.trim(), password);
      nav(loc.state?.from ?? '/admin', { replace: true });
    } catch (err) { setError(apiErrorMessage(err)); setAttempt((a) => a + 1); } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen grid lg:grid-cols-[minmax(0,1fr)_minmax(0,1.1fr)]">
      <div className="relative flex items-center justify-center p-6 lg:p-12 bg-white overflow-hidden">
        <div className="absolute -top-32 -left-32 w-96 h-96 rounded-full bg-emerald-100 blur-3xl opacity-70" />
        <div className="absolute inset-0 bg-dots-soft opacity-60" />
        <Stagger className="relative w-full max-w-md" gap={0.09} delay={0.05}>
          <StaggerItem>
            <div className="flex items-center gap-3">
              <div className="relative">
                <span className="absolute inset-0 rounded-2xl bg-emerald-400/50 blur-md" />
                <div className="relative w-11 h-11 rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-700 flex items-center justify-center text-white font-display text-xl shadow-lg">ኢ</div>
              </div>
              <div className="leading-tight">
                <div className="font-semibold text-emerald-950">EthioMarket</div>
                <div className="text-[10px] uppercase tracking-[0.2em] text-emerald-800/70">Admin Console</div>
              </div>
            </div>
          </StaggerItem>
          <StaggerItem>
            <h1 className="mt-10 font-display text-4xl sm:text-5xl text-emerald-950">Welcome back.</h1>
            <p className="mt-3 text-ink-600">Sign in with your administrator account to continue.</p>
          </StaggerItem>
          <StaggerItem>
            <form className="mt-8 space-y-4" onSubmit={submit}>
              <Input label="Email or phone" icon={<Mail />} placeholder="admin@ethiomarket.local" value={identifier} onChange={(e) => setIdentifier(e.target.value)} autoComplete="username" required />
              <Input label="Password" type="password" icon={<Lock />} placeholder="••••••••" value={password} onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" required />
              <AnimatePresence>
                {error && (
                  <motion.div key={attempt} initial={{ opacity: 0, height: 0, y: -6 }} animate={{ opacity: 1, height: 'auto', y: 0 }} exit={{ opacity: 0, height: 0 }}
                    className="rounded-2xl bg-red-50 text-red-700 text-sm px-4 py-3 ring-1 ring-red-200 flex items-start gap-2.5 animate-shake overflow-hidden">
                    <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" /> {error}
                  </motion.div>
                )}
              </AnimatePresence>
              <Button type="submit" loading={loading} size="lg" className="w-full">Sign in <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" /></Button>
            </form>
          </StaggerItem>
          <StaggerItem>
            <div className="mt-8 flex items-center gap-2.5 text-xs text-ink-500 p-3.5 rounded-2xl bg-emerald-50/70 border border-emerald-100">
              <ShieldCheck className="w-4 h-4 text-emerald-700 shrink-0" />
              All actions in this console are recorded in the audit log.
            </div>
          </StaggerItem>
        </Stagger>
      </div>

      <div className="relative hidden lg:flex overflow-hidden bg-emerald-950 text-emerald-50">
        <div className="absolute inset-0">
          <div className="absolute -top-40 -left-20 w-[34rem] h-[34rem] rounded-full bg-emerald-600/40 blur-3xl animate-aurora" />
          <div className="absolute -bottom-40 -right-20 w-[34rem] h-[34rem] rounded-full bg-teal-500/25 blur-3xl animate-aurora-rev" />
          <div className="absolute inset-0 bg-grid-light opacity-60 mask-fade-b" />
        </div>
        <div className="relative flex flex-col justify-between w-full p-14">
          <div>
            <motion.h2 initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8, delay: 0.2 }}
              className="font-display text-5xl xl:text-6xl leading-[1.08] max-w-xl text-balance">
              The operations console for a <span className="text-gold-300">trusted</span> marketplace.
            </motion.h2>
            <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8, delay: 0.4 }} className="mt-6 text-emerald-100/80 max-w-md leading-relaxed">
              Verify importers. Review payment evidence. Oversee disputes. Reconcile revenue. Every action audited, every number traceable.
            </motion.p>
          </div>

          <div className="relative -mx-6">
            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 1, delay: 0.3 }}>
              <TradeScene className="w-full h-auto max-h-[46vh]" />
            </motion.div>
            {features.map((f) => (
              <motion.div key={f.label} initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.9 + f.delay * 0.2, type: 'spring' }}
                className={`absolute ${f.cls}`}>
                <div className="animate-float" style={{ animationDelay: `${f.delay}s` }}>
                  <div className="flex items-center gap-2 px-3.5 py-2 rounded-2xl bg-white/10 border border-white/20 backdrop-blur-md text-sm font-medium shadow-lg">
                    <f.icon className="w-4 h-4 text-emerald-300" /> {f.label}
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
