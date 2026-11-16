import { Fragment, useState } from 'react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { Hourglass, FileText, BadgeCheck, Ban, Undo2, ArrowRight, Landmark, Wallet } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { Card, CardHeader } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { Button } from '@/components/common/Button';
import { Skeleton } from '@/components/common/Skeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { EmptyState } from '@/components/common/EmptyState';
import { PageHero } from '@/components/pro/PageHero';
import { SegmentedFilter } from '@/components/pro/FilterBar';
import { CountUp, ease } from '@/components/pro/motion';
import {
  useCommissionRecords, useRevenueSummary, useTransitionRevenue,
} from './useCommissions';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';
import type { CommissionRecord } from '@/api/commissions.api';

const tone = { pending: 'amber', invoiced: 'blue', received: 'emerald', waived: 'slate', refunded: 'red' } as const;

const nextState: Record<CommissionRecord['revenueState'], string[]> = {
  pending: ['invoiced', 'waived'],
  invoiced: ['received', 'refunded', 'waived'],
  received: ['refunded'],
  waived: [],
  refunded: [],
};

type Key = CommissionRecord['revenueState'];
const META: Record<Key, { icon: LucideIcon; grad: string; ring: string; chip: string }> = {
  pending: { icon: Hourglass, grad: 'from-amber-300 to-amber-500', ring: 'ring-amber-300/60', chip: 'bg-amber-100 text-amber-800' },
  invoiced: { icon: FileText, grad: 'from-sky-400 to-sky-600', ring: 'ring-sky-300/60', chip: 'bg-sky-100 text-sky-800' },
  received: { icon: BadgeCheck, grad: 'from-emerald-400 to-emerald-700', ring: 'ring-emerald-300/60', chip: 'bg-emerald-100 text-emerald-800' },
  waived: { icon: Ban, grad: 'from-slate-300 to-slate-500', ring: 'ring-slate-300/60', chip: 'bg-slate-100 text-slate-700' },
  refunded: { icon: Undo2, grad: 'from-rose-400 to-red-600', ring: 'ring-rose-300/60', chip: 'bg-rose-100 text-rose-800' },
};

function FlowArrow() {
  return (
    <div className="hidden md:flex items-center w-14 xl:w-20 shrink-0">
      <div className="relative w-full h-[3px] rounded-full bg-ink-200 overflow-visible">
        <motion.span className="absolute -top-[3px] w-[9px] h-[9px] rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.8)]"
          animate={{ left: ['0%', '100%'], opacity: [0, 1, 1, 0] }} transition={{ duration: 1.8, repeat: Infinity, ease: 'easeInOut' }} />
        <ArrowRight className="absolute -right-2 -top-[9px] w-5 h-5 text-ink-300" />
      </div>
    </div>
  );
}

function FlowNode({ k, i, total, count, selected, onSelect }: { k: Key; i: number; total: number; count: number; selected: boolean; onSelect: () => void }) {
  const m = META[k];
  return (
    <motion.button type="button" onClick={onSelect} initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 + i * 0.08, duration: 0.5, ease }}
      whileHover={{ y: -4 }} className={`relative text-left flex-1 min-w-0 rounded-3xl bg-white border p-5 shadow-card transition-all ${selected ? `ring-4 ${m.ring} border-transparent` : 'border-ink-200/70 hover:border-emerald-200'}`}>
      <div className={`w-11 h-11 rounded-2xl bg-gradient-to-br ${m.grad} text-white flex items-center justify-center shadow-lg`}><m.icon className="w-5 h-5" /></div>
      <div className="mt-4 text-sm text-ink-500">{humanize(k)}</div>
      <div className="mt-1 text-2xl font-semibold text-emerald-950 truncate"><CountUp value={total} format={fmtETB} /></div>
      <div className={`inline-flex mt-2 px-2 py-0.5 rounded-full text-[11px] font-medium ${m.chip}`}>{count} record(s)</div>
    </motion.button>
  );
}

export default function ReconciliationPage() {
  const [state, setState] = useState('pending');
  const summary = useRevenueSummary();
  const records = useCommissionRecords({ revenueState: state || undefined });
  const transition = useTransitionRevenue();

  const nodeFor = (k: Key, i: number) => summary.data ? <FlowNode key={k} k={k} i={i} total={summary.data[k].total} count={summary.data[k].count} selected={state === k} onSelect={() => setState(state === k ? '' : k)} /> : null;
  const earned = summary.data ? summary.data.pending.total + summary.data.invoiced.total + summary.data.received.total : 0;

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Finance" eyebrowIcon={Landmark}
        title="Revenue reconciliation"
        subtitle="Earned, invoiced, and received — kept strictly separate so the books always tell the truth."
        art="reconciliation"
        stats={summary.data ? [
          { label: 'Pending', value: <CountUp value={summary.data.pending.total} format={fmtETB} />, icon: Hourglass },
          { label: 'Invoiced', value: <CountUp value={summary.data.invoiced.total} format={fmtETB} />, icon: FileText },
          { label: 'Received', value: <CountUp value={summary.data.received.total} format={fmtETB} />, icon: BadgeCheck },
          { label: 'Total earned', value: <CountUp value={earned} format={fmtETB} />, icon: Wallet },
        ] : undefined}
      />

      {summary.isLoading && <Skeleton className="h-44 rounded-3xl" />}
      {summary.isError && <Card><ErrorState message="Failed to load revenue summary." onRetry={() => summary.refetch()} /></Card>}
      {summary.data && (
        <div className="space-y-4">
          <div className="flex flex-col md:flex-row md:items-stretch gap-3 md:gap-0">
            {(["pending", "invoiced", "received"] as Key[]).map((k, i) => (<Fragment key={k}>{i > 0 && <FlowArrow />}{nodeFor(k, i)}</Fragment>))}
          </div>
          <div className="grid sm:grid-cols-2 gap-3">
            {nodeFor("waived", 3)}{nodeFor("refunded", 4)}
          </div>
          <p className="text-xs text-ink-500 text-center">Tap a state to filter the records below.</p>
        </div>
      )}

      <Card className="overflow-hidden">
        <CardHeader icon={Landmark} title="Commission records" subtitle="Advance state as invoices settle" />
        <div className="p-4 border-b border-ink-100">
          <SegmentedFilter
            value={state} onChange={setState}
            options={[{ value: '', label: 'All' }, { value: 'pending', label: 'Pending' }, { value: 'invoiced', label: 'Invoiced' }, { value: 'received', label: 'Received' }, { value: 'waived', label: 'Waived' }, { value: 'refunded', label: 'Refunded' }]}
          />
        </div>
        {records.isError ? (
          <ErrorState message="Failed to load records." onRetry={() => records.refetch()} />
        ) : (
          <Table<CommissionRecord>
            keyFn={(r) => r._id}
            loading={records.isLoading}
            rows={records.data?.items ?? []}
            empty={<EmptyState title="No records in this state" icon={Landmark} />}
            columns={[
              { key: 'order', header: 'Order', render: (r) => <span className="font-semibold text-emerald-900">{typeof r.order === 'object' ? r.order.referenceNumber : r.order}</span> },
              { key: 'rule', header: 'Rule', render: (r) => <span className="font-mono text-xs text-ink-500">{r.ruleVersion}</span> },
              { key: 'orderVal', header: 'Order value', render: (r) => fmtETB(r.orderValueETB) },
              { key: 'fee', header: 'Fee', render: (r) => <span className="font-semibold">{fmtETB(r.computedFeeETB)}</span> },
              { key: 'payer', header: 'Payer', render: (r) => humanize(r.payer) },
              { key: 'state', header: 'State', render: (r) => <Badge tone={tone[r.revenueState]} dot>{humanize(r.revenueState)}</Badge> },
              { key: 'created', header: 'Created', render: (r) => fmtDate(r.createdAt) },
              {
                key: 'actions', header: '',
                render: (r) => (
                  <div className="flex gap-1.5 justify-end">
                    {nextState[r.revenueState].map((to) => (
                      <Button key={to} size="sm" variant="soft" onClick={async () => {
                        await transition.mutateAsync({ id: r._id, to });
                        toast.success(`Moved to ${humanize(to)}`);
                      }}><ArrowRight className="w-3 h-3" /> {humanize(to)}</Button>
                    ))}
                  </div>
                ),
              },
            ]}
          />
        )}
      </Card>
    </div>
  );
}
