import { useState } from 'react';
import { ClipboardList, Megaphone, Handshake, FileSignature, MapPin, CalendarClock } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SearchField, SegmentedFilter } from '@/components/pro/FilterBar';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp } from '@/components/pro/motion';
import { useDebounce } from '@/hooks/useDebounce';
import { useAdminRequests } from './useRequests';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';
import type { AdminProductRequest } from '@/api/requests.api';

const tone: Record<string, 'slate' | 'blue' | 'gold' | 'emerald' | 'red' | 'amber'> = {
  draft: 'slate', published: 'blue', receiving_offers: 'gold', offer_selected: 'emerald',
  fulfilled: 'emerald', cancelled: 'slate', expired: 'slate', rejected_by_admin: 'red',
};
const FILTERS = [
  { value: '', label: 'All' }, { value: 'draft', label: 'Draft' }, { value: 'published', label: 'Published' },
  { value: 'receiving_offers', label: 'Receiving offers' }, { value: 'offer_selected', label: 'Offer selected' },
  { value: 'fulfilled', label: 'Fulfilled' }, { value: 'cancelled', label: 'Cancelled' },
  { value: 'expired', label: 'Expired' }, { value: 'rejected_by_admin', label: 'Rejected' },
];

export default function RequestsPage() {
  const [status, setStatus] = useState('');
  const [q, setQ] = useState('');
  const debounced = useDebounce(q, 300);
  const query = useAdminRequests({ status: status || undefined, q: debounced || undefined, limit: 100 });
  const items = query.data?.items ?? [];

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Read-only" eyebrowIcon={ClipboardList}
        title="Requests"
        subtitle="Every buyer request across the platform, from first draft to fulfilment."
        art="requests"
        stats={[
          { label: 'In view', value: <CountUp value={items.length} />, icon: ClipboardList },
          { label: 'Live', value: <CountUp value={items.filter((r) => r.status === 'published' || r.status === 'receiving_offers').length} />, icon: Megaphone },
          { label: 'Offer selected', value: <CountUp value={items.filter((r) => r.status === 'offer_selected').length} />, icon: Handshake },
          { label: 'Quotes received', value: <CountUp value={items.reduce((s, r) => s + (r.quotationsCount ?? 0), 0)} />, icon: FileSignature },
        ]}
      />

      <FilterBar>
        <SearchField value={q} onChange={setQ} placeholder="Search by title…" />
        <SegmentedFilter options={FILTERS} value={status} onChange={setStatus} />
      </FilterBar>

      <Card className="overflow-hidden">
        {query.isError ? <ErrorState message="Failed to load requests." onRetry={() => query.refetch()} /> : (
          <Table<AdminProductRequest>
            keyFn={(r) => r._id}
            loading={query.isLoading}
            rows={items}
            empty={<EmptyState title="No requests in this view" description="Try clearing the search or status filter." icon={ClipboardList} />}
            columns={[
              { key: 'ref', header: 'Reference', render: (r) => <span className="font-mono text-xs text-ink-500">{r.referenceNumber}</span> },
              {
                key: 'title', header: 'Request',
                render: (r) => (
                  <div className="max-w-[260px]">
                    <div className="font-semibold text-ink-900 truncate">{r.title}</div>
                    <div className="text-xs text-ink-500 truncate">{r.category?.name ?? '—'} · {r.quantity} {r.unitOfMeasurement}</div>
                  </div>
                ),
              },
              {
                key: 'buyer', header: 'Buyer',
                render: (r) => (
                  <div className="flex items-center gap-2.5"><Avatar name={r.buyer?.fullName} size={32} /><div><div className="font-medium">{r.buyer?.fullName ?? '—'}</div><div className="text-xs text-ink-500">{r.buyer?.email ?? ''}</div></div></div>
                ),
              },
              { key: 'city', header: 'City', render: (r) => <span className="inline-flex items-center gap-1.5"><MapPin className="w-3.5 h-3.5 text-ink-400" />{r.deliveryCity}</span> },
              {
                key: 'budget', header: 'Budget',
                render: (r) => (r.budgetMinETB != null || r.budgetMaxETB != null) ? <span className="text-sm">{fmtETB(r.budgetMinETB)} – {fmtETB(r.budgetMaxETB)}</span> : <span className="text-ink-400">Open</span>,
              },
              { key: 'quotes', header: 'Quotes', render: (r) => <span className={`inline-flex items-center justify-center min-w-[28px] h-7 px-2 rounded-full text-xs font-semibold ${r.quotationsCount > 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-ink-100 text-ink-500'}`}>{r.quotationsCount}</span> },
              { key: 'status', header: 'Status', render: (r) => <Badge tone={tone[r.status] ?? 'slate'} dot>{humanize(r.status)}</Badge> },
              { key: 'expires', header: 'Expires', render: (r) => <span className="inline-flex items-center gap-1.5 text-ink-600"><CalendarClock className="w-3.5 h-3.5 text-ink-400" />{fmtDate(r.expiresAt)}</span> },
            ]}
          />
        )}
      </Card>
    </div>
  );
}
