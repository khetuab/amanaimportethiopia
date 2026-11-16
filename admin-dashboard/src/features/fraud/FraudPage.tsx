import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { ShieldAlert, Search, CheckCircle2, ShieldX, User, Package, Siren, Eye, Gavel, Quote } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Badge } from '@/components/common/Badge';
import { Button } from '@/components/common/Button';
import { Textarea } from '@/components/common/Input';
import { Modal } from '@/components/common/Modal';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { SkeletonCards } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SegmentedFilter } from '@/components/pro/FilterBar';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { listFraudReports, updateFraudReport, type FraudReport } from '@/api/admin.api';
import { fmtDate, humanize, relativeTime } from '@/lib/formatters';

const tone = { open: 'red', investigating: 'amber', resolved_no_action: 'slate', resolved_action_taken: 'emerald' } as const;
const FILTERS = [
  { value: 'open', label: 'Open' }, { value: 'investigating', label: 'Investigating' },
  { value: 'resolved_no_action', label: 'No action' }, { value: 'resolved_action_taken', label: 'Action taken' }, { value: '', label: 'All' },
];
const STATUS_OPTIONS: { value: FraudReport['status']; label: string; hint: string; icon: typeof Eye }[] = [
  { value: 'open', label: 'Open', hint: 'Not yet looked at.', icon: Siren },
  { value: 'investigating', label: 'Investigating', hint: 'Currently being checked.', icon: Eye },
  { value: 'resolved_no_action', label: 'Resolved — no action', hint: 'Nothing wrong was found.', icon: CheckCircle2 },
  { value: 'resolved_action_taken', label: 'Resolved — action taken', hint: 'Accounts or orders were acted on.', icon: Gavel },
];

export default function FraudPage() {
  const qc = useQueryClient();
  const [status, setStatus] = useState('open');
  const q = useQuery({ queryKey: ['fraud', status], queryFn: () => listFraudReports({ status: status || undefined, limit: 50 }) });
  const [editing, setEditing] = useState<FraudReport | null>(null);
  const [newStatus, setNewStatus] = useState<FraudReport['status']>('investigating');
  const [notes, setNotes] = useState('');
  const items = q.data?.items ?? [];

  const mut = useMutation({
    mutationFn: async () => (editing ? updateFraudReport(editing._id, { status: newStatus, notes }) : null),
    onSuccess: () => {
      toast.success('Fraud report updated');
      qc.invalidateQueries({ queryKey: ['fraud'] });
      setEditing(null);
    },
  });

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Trust & safety" eyebrowIcon={ShieldAlert}
        title="Fraud reports"
        subtitle="Suspicious activity, off-platform solicitation, counterfeit goods. Triage quickly and leave a clear paper trail."
        art="fraud"
        stats={[
          { label: 'In this view', value: <CountUp value={items.length} />, icon: ShieldAlert },
          { label: 'Open', value: <CountUp value={items.filter((r) => r.status === 'open').length} />, icon: Siren },
          { label: 'Investigating', value: <CountUp value={items.filter((r) => r.status === 'investigating').length} />, icon: Search },
          { label: 'Resolved', value: <CountUp value={items.filter((r) => r.status.startsWith('resolved')).length} />, icon: CheckCircle2 },
        ]}
      />

      <FilterBar><SegmentedFilter options={FILTERS} value={status} onChange={setStatus} /></FilterBar>

      {q.isError ? (
        <Card><ErrorState message="Failed to load fraud reports." onRetry={() => q.refetch()} /></Card>
      ) : q.isLoading ? <SkeletonCards count={4} /> : items.length === 0 ? (
        <Card><EmptyState title="No fraud reports" description="Good sign." icon={ShieldX} /></Card>
      ) : (
        <Stagger className="grid gap-5 md:grid-cols-2" gap={0.06} key={status}>
          {items.map((r) => (
            <StaggerItem key={r._id}>
              <Card hover className="h-full overflow-hidden flex flex-col">
                <div className={`h-1.5 ${r.status === 'open' ? 'bg-gradient-to-r from-rose-400 to-red-600' : r.status === 'investigating' ? 'bg-gradient-to-r from-amber-300 to-amber-500' : 'bg-gradient-to-r from-emerald-400 to-emerald-600'}`} />
                <div className="p-5 flex-1">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-11 h-11 shrink-0 rounded-2xl bg-red-50 text-red-600 flex items-center justify-center"><ShieldAlert className="w-5 h-5" /></div>
                      <div className="min-w-0"><div className="font-semibold text-ink-900 truncate">{humanize(r.category)}</div><div className="text-xs text-ink-500">{fmtDate(r.createdAt)} · {relativeTime(r.createdAt)}</div></div>
                    </div>
                    <Badge tone={tone[r.status]} pulse={r.status === 'open'}>{humanize(r.status)}</Badge>
                  </div>
                  <div className="relative mt-4 rounded-2xl bg-ink-50 p-4 text-sm text-ink-700 leading-relaxed"><Quote className="absolute top-2 right-3 w-6 h-6 text-ink-200" /><span className="line-clamp-3">{r.description}</span></div>
                  <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2 text-sm text-ink-600">
                    <span className="inline-flex items-center gap-2"><Avatar name={r.reporter?.fullName ?? 'Anonymous'} size={26} />{r.reporter?.fullName || 'Anonymous'}</span>
                    {r.relatedUser?.fullName && <span className="inline-flex items-center gap-1.5"><User className="w-4 h-4 text-ink-400" />About {r.relatedUser.fullName}</span>}
                    {r.relatedOrder?.referenceNumber && <span className="inline-flex items-center gap-1.5"><Package className="w-4 h-4 text-ink-400" />{r.relatedOrder.referenceNumber}</span>}
                  </div>
                </div>
                <div className="px-5 pb-5">
                  <Button size="sm" variant="secondary" className="w-full" onClick={() => { setEditing(r); setNewStatus(r.status); setNotes(r.adminNotes ?? ''); }}>
                    <Gavel className="w-3.5 h-3.5" /> Triage
                  </Button>
                </div>
              </Card>
            </StaggerItem>
          ))}
        </Stagger>
      )}

      <Modal
        open={!!editing} onClose={() => setEditing(null)} title="Triage fraud report" subtitle={editing ? humanize(editing.category) : undefined} icon={ShieldAlert} width="max-w-xl"
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            <Button loading={mut.isPending} onClick={() => mut.mutate()}>Save</Button>
          </>
        }
      >
        {editing && (
          <div className="space-y-5">
            <div className="rounded-2xl bg-ink-50 p-4 text-sm text-ink-700 leading-relaxed">{editing.description}</div>
            <div>
              <span className="block text-sm font-medium text-ink-700 mb-2">New status</span>
              <div className="grid sm:grid-cols-2 gap-2.5">
                {STATUS_OPTIONS.map((o) => {
                  const on = newStatus === o.value;
                  return (
                    <button key={o.value} type="button" onClick={() => setNewStatus(o.value)}
                      className={`flex items-start gap-3 text-left rounded-2xl border px-3.5 py-3 transition-all ${on ? 'border-emerald-500 bg-emerald-50 shadow-[0_0_0_4px_rgba(16,185,129,0.12)]' : 'border-ink-200 hover:border-emerald-300'}`}>
                      <motion.span animate={{ scale: on ? 1.1 : 1 }} className={`w-9 h-9 shrink-0 rounded-xl flex items-center justify-center ${on ? 'bg-emerald-600 text-white' : 'bg-ink-100 text-ink-500'}`}><o.icon className="w-4 h-4" /></motion.span>
                      <span><span className="block text-sm font-semibold text-ink-900">{o.label}</span><span className="block text-xs text-ink-500">{o.hint}</span></span>
                    </button>
                  );
                })}
              </div>
            </div>
            <Textarea label="Notes" value={notes} onChange={(e) => setNotes(e.target.value)} className="min-h-[90px]" />
          </div>
        )}
      </Modal>
    </div>
  );
}
