import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { ShieldCheck, AlertTriangle, Circle, Search, FileCheck2, Power, Lock } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Skeleton } from '@/components/common/Skeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { ProgressRing } from '@/components/pro/ProgressRing';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { useLegalChecklist, useUpdateLegalItem } from './useSettings';
import { fmtDate, humanize } from '@/lib/formatters';
import type { LegalChecklistItem } from '@/api/admin.api';

type S = LegalChecklistItem['status'];
const STEPS: { value: S; label: string; icon: typeof Circle }[] = [
  { value: 'not_started', label: 'Not started', icon: Circle },
  { value: 'in_review', label: 'In review', icon: Search },
  { value: 'advice_obtained', label: 'Advice obtained', icon: FileCheck2 },
  { value: 'enabled', label: 'Enabled', icon: Power },
];
const rank = (s: S) => STEPS.findIndex((x) => x.value === s);

export default function SettingsPage() {
  const q = useLegalChecklist();
  const mut = useUpdateLegalItem();

  if (q.isLoading) return <div className="space-y-5"><Skeleton className="h-64 rounded-[28px]" /><Skeleton className="h-64 rounded-3xl" /></div>;
  if (q.isError) return <ErrorState message="Failed to load checklist." onRetry={() => q.refetch()} />;

  const items = q.data ?? [];
  const enabled = items.filter((i) => i.status === 'enabled').length;
  const pct = items.length ? (enabled / items.length) * 100 : 0;
  const groups = items.reduce<Record<string, LegalChecklistItem[]>>((acc, it) => {
    (acc[it.category] ||= []).push(it);
    return acc;
  }, {});

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Compliance tracking" eyebrowIcon={ShieldCheck}
        title="Legal review checklist"
        subtitle={<>Tracking only. <b className="text-white">This is not a compliance claim.</b> Manual payments must remain disabled until the corresponding items reach <i>enabled</i> with professional advice on file.</>}
        art={<ProgressRing light value={pct} size={190} stroke={14} sub="Enabled" />}
        stats={[
          { label: 'Checklist items', value: <CountUp value={items.length} />, icon: ShieldCheck },
          { label: 'Enabled', value: <CountUp value={enabled} />, icon: Power },
          { label: 'In progress', value: <CountUp value={items.filter((i) => i.status === 'in_review' || i.status === 'advice_obtained').length} />, icon: Search },
          { label: 'Not started', value: <CountUp value={items.filter((i) => i.status === 'not_started').length} />, icon: Circle },
        ]}
      />

      <div className="flex items-start gap-3 rounded-2xl bg-amber-50 text-amber-900 ring-1 ring-amber-200 px-5 py-4 text-sm">
        <AlertTriangle className="w-5 h-5 shrink-0 mt-0.5" />
        <p>Moving an item to <b>Enabled</b> is a statement that professional legal advice is on file. Changes are recorded in the audit log.</p>
      </div>

      {Object.entries(groups).map(([cat, list]) => {
        const done = list.filter((i) => i.status === 'enabled').length;
        return (
          <Card key={cat} className="overflow-hidden">
            <div className="px-6 py-5 border-b border-ink-100 flex items-center justify-between gap-4 bg-gradient-to-r from-emerald-50/60 to-white">
              <h3 className="font-semibold text-emerald-950">{humanize(cat)}</h3>
              <div className="flex items-center gap-3 text-xs text-ink-500">
                <div className="w-28 h-2 rounded-full bg-ink-100 overflow-hidden"><motion.div className="h-full bg-gradient-to-r from-emerald-400 to-emerald-600 rounded-full" initial={{ width: 0 }} animate={{ width: `${(done / list.length) * 100}%` }} transition={{ duration: 0.9 }} /></div>
                {done}/{list.length}
              </div>
            </div>
            <Stagger className="divide-y divide-ink-100" gap={0.04}>
              {list.map((it) => {
                const r = rank(it.status);
                return (
                  <StaggerItem key={it._id}>
                    <div className="p-5 grid lg:grid-cols-[1fr_auto] gap-4 items-center">
                      <div className="min-w-0">
                        <div className="font-medium text-ink-900">{it.label}</div>
                        <div className="text-xs text-ink-500 mt-1 flex flex-wrap items-center gap-x-3 gap-y-1">
                          {it.gatesCapability && <span className="inline-flex items-center gap-1"><Lock className="w-3 h-3" />Gates <code className="font-mono bg-ink-100 rounded px-1.5 py-0.5">{it.gatesCapability}</code></span>}
                          {it.reviewedAt && <span>Last reviewed {fmtDate(it.reviewedAt)}</span>}
                        </div>
                      </div>
                      <div className="flex items-center rounded-2xl bg-ink-50 border border-ink-200 p-1 gap-1 overflow-x-auto no-scrollbar">
                        {STEPS.map((s, i) => {
                          const on = i === r;
                          const passed = i < r;
                          return (
                            <button key={s.value} disabled={mut.isPending} onClick={async () => {
                              if (on) return;
                              await mut.mutateAsync({ item: it.item, status: s.value });
                              toast.success('Checklist updated');
                            }}
                              className={`relative whitespace-nowrap inline-flex items-center gap-1.5 px-3 h-9 rounded-xl text-xs font-medium transition-colors ${on ? 'text-white' : passed ? 'text-emerald-700' : 'text-ink-500 hover:text-ink-800 hover:bg-white'}`}>
                              {on && <motion.span layoutId={`legal-${it._id}`} className={`absolute inset-0 rounded-xl ${s.value === 'enabled' ? 'bg-gradient-to-br from-emerald-500 to-emerald-700' : s.value === 'not_started' ? 'bg-ink-500' : s.value === 'in_review' ? 'bg-amber-500' : 'bg-sky-600'}`} transition={{ type: 'spring', stiffness: 420, damping: 34 }} />}
                              <span className="relative inline-flex items-center gap-1.5"><s.icon className="w-3.5 h-3.5" />{s.label}</span>
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  </StaggerItem>
                );
              })}
            </Stagger>
          </Card>
        );
      })}

      {items.length === 0 && (
        <Card><div className="p-10 text-center text-ink-500">No checklist items seeded. Run <code className="font-mono bg-ink-100 rounded px-1.5 py-0.5">npm run seed:legal</code> in the backend.</div></Card>
      )}
    </div>
  );
}
