import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import {
  ScrollText, BadgeCheck, CreditCard, Package, Scale, Percent, Tags, ShieldAlert, Activity, Users, Fingerprint, Clock, Hash,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { Skeleton } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SearchField } from '@/components/pro/FilterBar';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { useDebounce } from '@/hooks/useDebounce';
import { useAuditLogs } from './useAuditLogs';
import { fmtDate, humanize } from '@/lib/formatters';
import type { AuditLogEntry } from '@/api/admin.api';

const QUICK = [
  { label: 'Importers', value: 'importer', icon: BadgeCheck }, { label: 'Payments', value: 'payment', icon: CreditCard },
  { label: 'Orders', value: 'order', icon: Package }, { label: 'Disputes', value: 'dispute', icon: Scale },
  { label: 'Commissions', value: 'commission', icon: Percent }, { label: 'Categories', value: 'category', icon: Tags },
  { label: 'Fraud', value: 'fraud', icon: ShieldAlert },
];

function iconFor(a: string): LucideIcon {
  const s = a.toLowerCase();
  if (s.includes('importer')) return BadgeCheck;
  if (s.includes('payment')) return CreditCard;
  if (s.includes('order')) return Package;
  if (s.includes('dispute')) return Scale;
  if (s.includes('commission') || s.includes('revenue')) return Percent;
  if (s.includes('categor')) return Tags;
  if (s.includes('fraud')) return ShieldAlert;
  return Activity;
}
function toneFor(a: string) {
  const s = a.toLowerCase();
  if (/(approve|verify|reinstate|enable|resolve|activate)/.test(s)) return 'bg-emerald-50 text-emerald-700 ring-emerald-200';
  if (/(reject|suspend|delete|cancel|deactivate|reverse|refund)/.test(s)) return 'bg-red-50 text-red-700 ring-red-200';
  if (/(create|add|send)/.test(s)) return 'bg-sky-50 text-sky-700 ring-sky-200';
  return 'bg-ink-100 text-ink-700 ring-ink-200';
}
const time = (iso: string) => new Date(iso).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });

export default function AuditLogsPage() {
  const [action, setAction] = useState('');
  const debounced = useDebounce(action, 300);
  const q = useAuditLogs({ action: debounced || undefined, limit: 100 });
  const items = q.data?.items ?? [];

  const groups = useMemo(() => {
    const m = new Map<string, AuditLogEntry[]>();
    items.forEach((e) => { const k = fmtDate(e.createdAt); m.set(k, [...(m.get(k) ?? []), e]); });
    return [...m.entries()];
  }, [items]);
  const actors = new Set(items.map((e) => (typeof e.actor === 'object' ? e.actor._id : e.actor))).size;

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Immutable record" eyebrowIcon={Fingerprint}
        title="Audit log"
        subtitle="Every privileged action is recorded — who did it, what changed, and when. Nothing here can be edited."
        art="audit"
        stats={[
          { label: 'Entries loaded', value: <CountUp value={items.length} />, icon: ScrollText },
          { label: 'Distinct actors', value: <CountUp value={actors} />, icon: Users },
          { label: 'Days covered', value: <CountUp value={groups.length} />, icon: Clock },
        ]}
      />

      <FilterBar>
        <SearchField value={action} onChange={setAction} placeholder="Filter by action, e.g. importer.approve" />
      </FilterBar>
      <div className="flex flex-wrap gap-2 -mt-2">
        {QUICK.map((c) => (
          <button key={c.value} onClick={() => setAction(action === c.value ? '' : c.value)}
            className={`inline-flex items-center gap-1.5 px-3.5 h-9 rounded-full text-sm border transition-all ${action === c.value ? 'bg-emerald-700 text-white border-emerald-700 shadow-md' : 'bg-white text-ink-600 border-ink-200 hover:border-emerald-300 hover:text-emerald-800'}`}>
            <c.icon className="w-3.5 h-3.5" />{c.label}
          </button>
        ))}
      </div>

      {q.isError ? (
        <Card><ErrorState message="Failed to load audit log." onRetry={() => q.refetch()} /></Card>
      ) : q.isLoading ? (
        <div className="space-y-3">{[0, 1, 2, 3].map((i) => <Skeleton key={i} className="h-20 rounded-3xl" />)}</div>
      ) : groups.length === 0 ? (
        <Card><EmptyState title="No audit entries" description="Nothing matches this filter yet." icon={ScrollText} /></Card>
      ) : (
        <div className="space-y-8">
          {groups.map(([day, entries]) => (
            <section key={day}>
              <div className="sticky top-[72px] z-10 mb-3"><span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/90 backdrop-blur border border-ink-200 shadow-card text-xs font-semibold text-ink-700"><Clock className="w-3.5 h-3.5 text-emerald-600" />{day} <span className="text-ink-400 font-normal">· {entries.length}</span></span></div>
              <Stagger className="relative space-y-3 pl-0 sm:pl-5" gap={0.04}>
                <div className="hidden sm:block absolute left-[7px] top-2 bottom-2 w-px bg-gradient-to-b from-emerald-300 via-ink-200 to-transparent" />
                {entries.map((e) => {
                  const Icon = iconFor(e.action);
                  const actor = typeof e.actor === 'object' ? e.actor : null;
                  return (
                    <StaggerItem key={e._id}>
                      <motion.div whileHover={{ x: 3 }} className="relative">
                        <span className="hidden sm:block absolute -left-5 top-6 w-[15px] h-[15px] rounded-full bg-white border-[3px] border-emerald-500" />
                        <Card className="p-4 flex items-start gap-4">
                          <Avatar name={actor?.fullName ?? 'System'} size={42} />
                          <div className="min-w-0 flex-1">
                            <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                              <span className="font-semibold text-ink-900">{actor?.fullName ?? 'System'}</span>
                              <span className="text-xs text-ink-400">{humanize(e.actorRole)}</span>
                            </div>
                            <div className="mt-1.5 flex flex-wrap items-center gap-2">
                              <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-mono ring-1 ${toneFor(e.action)}`}><Icon className="w-3.5 h-3.5" />{e.action}</span>
                              <span className="inline-flex items-center gap-1 text-xs text-ink-500"><Hash className="w-3 h-3" />{e.targetType}:<span className="font-mono">{e.targetId.slice(-6)}</span></span>
                            </div>
                            {e.summary && <p className="mt-2 text-sm text-ink-600">{e.summary}</p>}
                          </div>
                          <div className="text-xs text-ink-400 tabular-nums shrink-0 pt-1">{time(e.createdAt)}</div>
                        </Card>
                      </motion.div>
                    </StaggerItem>
                  );
                })}
              </Stagger>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}
