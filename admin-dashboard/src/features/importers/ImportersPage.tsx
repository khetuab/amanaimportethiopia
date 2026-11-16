import { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { CheckCircle2, Clock, XCircle, PauseCircle, Star, Package, MapPin, ArrowUpRight, BadgeCheck, Users, Hourglass, TimerOff } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { SkeletonCards } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SearchField, SegmentedFilter, ViewToggle } from '@/components/pro/FilterBar';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { useDebounce } from '@/hooks/useDebounce';
import { useImportersList } from './useImporters';
import { fmtDate, humanize } from '@/lib/formatters';
import type { ImporterProfile, VerificationStatus } from '@/types/importer.types';

const statusTone: Record<VerificationStatus, 'emerald' | 'amber' | 'red' | 'slate' | 'blue'> = {
  approved: 'emerald', pending: 'amber', rejected: 'red', suspended: 'slate', expired: 'blue',
};
const statusIcon = { approved: CheckCircle2, pending: Clock, rejected: XCircle, suspended: PauseCircle, expired: TimerOff } as const;

const FILTERS: { value: VerificationStatus | ''; label: string }[] = [
  { value: '', label: 'All' }, { value: 'pending', label: 'Pending' }, { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' }, { value: 'suspended', label: 'Suspended' }, { value: 'expired', label: 'Expired' },
];

export default function ImportersPage() {
  const nav = useNavigate();
  const [status, setStatus] = useState<VerificationStatus | ''>('');
  const [q, setQ] = useState('');
  const [view, setView] = useState<'cards' | 'table'>('cards');
  const debounced = useDebounce(q, 300);
  const query = useImportersList({ status: status || undefined, q: debounced || undefined });
  const rows = query.data ?? [];

  const stats = useMemo(() => {
    const rated = rows.filter((r) => (r.ratingCount ?? 0) > 0);
    return {
      approved: rows.filter((r) => r.verificationStatus === 'approved').length,
      pending: rows.filter((r) => r.verificationStatus === 'pending').length,
      avg: rated.length ? rated.reduce((s, r) => s + (r.ratingAverage ?? 0), 0) / rated.length : 0,
    };
  }, [rows]);

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Trust & verification" eyebrowIcon={BadgeCheck}
        title="Importers"
        subtitle="Verify licenses, review profiles, and control who may quote. Every decision is recorded in the audit log."
        art="importers"
        stats={[
          { label: 'In view', value: <CountUp value={rows.length} />, icon: Users },
          { label: 'Approved', value: <CountUp value={stats.approved} />, icon: CheckCircle2 },
          { label: 'Awaiting review', value: <CountUp value={stats.pending} />, icon: Hourglass },
          { label: 'Avg rating', value: <CountUp value={stats.avg} format={(n) => n.toFixed(1)} />, icon: Star },
        ]}
      />

      <FilterBar>
        <SearchField value={q} onChange={setQ} placeholder="Search business name…" />
        <SegmentedFilter options={FILTERS} value={status} onChange={setStatus} />
        <ViewToggle value={view} onChange={setView} />
      </FilterBar>

      {query.isError ? (
        <Card><ErrorState message="Failed to load importers." onRetry={() => query.refetch()} /></Card>
      ) : query.isLoading ? (
        <SkeletonCards />
      ) : rows.length === 0 ? (
        <Card><EmptyState title="No importers match your filter" description="Try clearing the search or status filter." icon={BadgeCheck} /></Card>
      ) : view === 'cards' ? (
        <Stagger className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3" gap={0.05} key={`${status}-${debounced}`}>
          {rows.map((r) => {
            const Icon = statusIcon[r.verificationStatus];
            return (
              <StaggerItem key={r._id}>
                <Link to={`/admin/importers/${r._id}`} className="group block h-full">
                  <Card hover className="h-full p-5 relative overflow-hidden">
                    <div className={`absolute inset-x-0 top-0 h-1 ${r.verificationStatus === 'approved' ? 'bg-emerald-500' : r.verificationStatus === 'pending' ? 'bg-amber-400' : r.verificationStatus === 'rejected' ? 'bg-red-500' : 'bg-ink-300'}`} />
                    <div className="flex items-start gap-4">
                      <Avatar name={r.businessName} size={52} />
                      <div className="min-w-0 flex-1">
                        <div className="font-semibold text-ink-900 truncate group-hover:text-emerald-800 transition-colors">{r.businessName}</div>
                        <div className="text-xs text-ink-500 truncate">{r.user?.fullName} · {r.user?.email}</div>
                        <div className="mt-2"><Badge tone={statusTone[r.verificationStatus]} pulse={r.verificationStatus === 'pending'}><Icon className="w-3 h-3" /> {humanize(r.verificationStatus)}</Badge></div>
                      </div>
                      <ArrowUpRight className="w-5 h-5 text-ink-300 group-hover:text-emerald-600 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-all" />
                    </div>
                    <div className="mt-5 grid grid-cols-3 gap-2 text-center">
                      <div className="rounded-2xl bg-ink-50 py-2.5"><div className="flex items-center justify-center gap-1 text-sm font-semibold text-ink-900"><Star className="w-3.5 h-3.5 fill-gold-400 text-gold-400" />{(r.ratingAverage ?? 0).toFixed(1)}</div><div className="text-[10px] text-ink-500 uppercase tracking-wide">{r.ratingCount ?? 0} reviews</div></div>
                      <div className="rounded-2xl bg-ink-50 py-2.5"><div className="flex items-center justify-center gap-1 text-sm font-semibold text-ink-900"><Package className="w-3.5 h-3.5 text-emerald-600" />{r.completedOrdersCount ?? 0}</div><div className="text-[10px] text-ink-500 uppercase tracking-wide">Completed</div></div>
                      <div className="rounded-2xl bg-ink-50 py-2.5"><div className="flex items-center justify-center gap-1 text-sm font-semibold text-ink-900"><MapPin className="w-3.5 h-3.5 text-emerald-600" />{(r.serviceAreas ?? []).length}</div><div className="text-[10px] text-ink-500 uppercase tracking-wide">Areas</div></div>
                    </div>
                    <div className="mt-4 text-xs text-ink-400">Submitted {fmtDate(r.createdAt)}</div>
                  </Card>
                </Link>
              </StaggerItem>
            );
          })}
        </Stagger>
      ) : (
        <Card className="overflow-hidden">
          <Table<ImporterProfile>
            keyFn={(r) => r._id}
            rows={rows}
            onRowClick={(r) => nav(`/admin/importers/${r._id}`)}
            columns={[
              {
                key: 'name', header: 'Business',
                render: (r) => (
                  <div className="flex items-center gap-3">
                    <Avatar name={r.businessName} size={36} />
                    <div><div className="font-medium text-emerald-900">{r.businessName}</div><div className="text-xs text-ink-500">{r.user?.fullName} · {r.user?.email}</div></div>
                  </div>
                ),
              },
              {
                key: 'status', header: 'Status',
                render: (r) => { const Icon = statusIcon[r.verificationStatus]; return <Badge tone={statusTone[r.verificationStatus]}><Icon className="w-3 h-3" /> {humanize(r.verificationStatus)}</Badge>; },
              },
              { key: 'orders', header: 'Completed', render: (r) => r.completedOrdersCount ?? 0 },
              { key: 'rating', header: 'Rating', render: (r) => <span className="inline-flex items-center gap-1"><Star className="w-3.5 h-3.5 fill-gold-400 text-gold-400" />{(r.ratingAverage ?? 0).toFixed(1)} <span className="text-ink-400">({r.ratingCount ?? 0})</span></span> },
              { key: 'created', header: 'Submitted', render: (r) => fmtDate(r.createdAt) },
            ]}
          />
        </Card>
      )}
    </div>
  );
}
