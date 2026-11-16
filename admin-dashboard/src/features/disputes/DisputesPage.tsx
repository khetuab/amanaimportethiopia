import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Scale, ShieldAlert, Search, CheckCircle2, Gavel, Flame } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { Avatar } from '@/components/pro/Avatar';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SegmentedFilter } from '@/components/pro/FilterBar';
import { CountUp } from '@/components/pro/motion';
import { useDisputesList } from './useDisputes';
import { fmtDate, humanize, relativeTime } from '@/lib/formatters';
import type { Dispute } from '@/api/disputes.api';

const statusTone = {
  open: 'red', under_review: 'amber', resolved_buyer_favor: 'emerald', resolved_importer_favor: 'emerald',
  resolved_mutual: 'emerald', withdrawn: 'slate',
} as const;

const FILTERS = [
  { value: 'open', label: 'Open' }, { value: 'under_review', label: 'Under review' },
  { value: 'resolved_buyer_favor', label: 'Buyer favor' }, { value: 'resolved_importer_favor', label: 'Importer favor' },
  { value: 'resolved_mutual', label: 'Mutual' }, { value: 'withdrawn', label: 'Withdrawn' }, { value: '', label: 'All' },
];

export default function DisputesPage() {
  const nav = useNavigate();
  const [status, setStatus] = useState('open');
  const q = useDisputesList({ status: status || undefined, limit: 100 });
  const items = q.data?.items ?? [];
  const ageDays = (iso: string) => Math.floor((Date.now() - new Date(iso).getTime()) / 86_400_000);
  const urgent = items.filter((d) => (d.status === 'open' || d.status === 'under_review') && ageDays(d.createdAt) >= 3).length;

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Conflict resolution" eyebrowIcon={Gavel}
        title="Disputes"
        subtitle="Open disputes block order completion until resolved. Review evidence, hear both sides, and record a fair outcome."
        art="disputes"
        stats={[
          { label: 'In this view', value: <CountUp value={items.length} />, icon: Scale },
          { label: 'Open', value: <CountUp value={items.filter((d) => d.status === 'open').length} />, icon: ShieldAlert },
          { label: 'Under review', value: <CountUp value={items.filter((d) => d.status === 'under_review').length} />, icon: Search },
          { label: 'Waiting 3+ days', value: <CountUp value={urgent} />, icon: Flame },
        ]}
      />

      <FilterBar><SegmentedFilter options={FILTERS} value={status} onChange={setStatus} /></FilterBar>

      <Card className="overflow-hidden">
        {q.isError ? <ErrorState message="Failed to load disputes." onRetry={() => q.refetch()} /> : (
          <Table<Dispute>
            keyFn={(r) => r._id}
            loading={q.isLoading}
            rows={items}
            onRowClick={(r) => nav(`/admin/disputes/${r._id}`)}
            empty={<EmptyState title={status === 'open' ? 'No open disputes' : 'No disputes in this view'} description={status === 'open' ? 'Everything is calm — nothing needs your judgment right now.' : 'Try a different status.'} icon={CheckCircle2} />}
            columns={[
              {
                key: 'order', header: 'Order',
                render: (r) => (
                  <Link to={`/admin/disputes/${r._id}`} onClick={(e) => e.stopPropagation()} className="font-semibold text-emerald-900 hover:underline">
                    {typeof r.order === 'object' ? r.order.referenceNumber : r.order}
                  </Link>
                ),
              },
              { key: 'reason', header: 'Reason', render: (r) => <span className="inline-flex items-center gap-2"><span className="w-1.5 h-6 rounded-full bg-gradient-to-b from-amber-300 to-red-400" />{humanize(r.reason)}</span> },
              {
                key: 'openedBy', header: 'Opened by',
                render: (r) => typeof r.openedBy === 'object'
                  ? <div className="flex items-center gap-2.5"><Avatar name={r.openedBy.fullName} size={30} /><div><div className="text-sm">{r.openedBy.fullName}</div><div className="text-[11px] text-ink-400 capitalize">{r.openedByRole}</div></div></div>
                  : '—',
              },
              { key: 'status', header: 'Status', render: (r) => <Badge tone={statusTone[r.status]} pulse={r.status === 'open'}>{humanize(r.status)}</Badge> },
              {
                key: 'created', header: 'Opened',
                render: (r) => {
                  const live = r.status === 'open' || r.status === 'under_review';
                  const d = ageDays(r.createdAt);
                  return <div><div>{fmtDate(r.createdAt)}</div><div className={`text-[11px] ${live && d >= 3 ? 'text-red-600 font-medium' : 'text-ink-400'}`}>{relativeTime(r.createdAt)}</div></div>;
                },
              },
            ]}
          />
        )}
      </Card>
    </div>
  );
}
