import { useState } from 'react';
import { Link } from 'react-router-dom';
import { FileSignature, Send, CheckCircle2, Banknote, Clock, Star } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SegmentedFilter } from '@/components/pro/FilterBar';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp } from '@/components/pro/motion';
import { useAdminQuotations } from './useQuotations';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';
import type { AdminQuotation } from '@/api/quotations.api';

const statusTone: Record<string, 'emerald' | 'amber' | 'red' | 'slate' | 'blue' | 'gold'> = {
  submitted: 'blue', updated: 'blue', withdrawn: 'slate', accepted: 'emerald', rejected: 'red', expired: 'slate',
};
const FILTERS = [
  { value: '', label: 'All' }, { value: 'submitted', label: 'Submitted' }, { value: 'updated', label: 'Updated' },
  { value: 'accepted', label: 'Accepted' }, { value: 'rejected', label: 'Rejected' },
  { value: 'withdrawn', label: 'Withdrawn' }, { value: 'expired', label: 'Expired' },
];

export default function QuotationsPage() {
  const [status, setStatus] = useState('');
  const q = useAdminQuotations({ status: status || undefined, limit: 100 });
  const items = q.data?.items ?? [];
  const avg = items.length ? items.reduce((s, r) => s + (r.totalPriceETB ?? 0), 0) / items.length : 0;

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Read-only monitoring" eyebrowIcon={FileSignature}
        title="Quotations"
        subtitle="Every importer offer on the platform. Watch pricing, delivery promises and acceptance as they happen."
        art="quotations"
        stats={[
          { label: 'In view', value: <CountUp value={items.length} />, icon: FileSignature },
          { label: 'Active offers', value: <CountUp value={items.filter((r) => r.status === 'submitted' || r.status === 'updated').length} />, icon: Send },
          { label: 'Accepted', value: <CountUp value={items.filter((r) => r.status === 'accepted').length} />, icon: CheckCircle2 },
          { label: 'Average price', value: <CountUp value={avg} format={fmtETB} />, icon: Banknote },
        ]}
      />

      <FilterBar><SegmentedFilter options={FILTERS} value={status} onChange={setStatus} /></FilterBar>

      <Card className="overflow-hidden">
        {q.isError ? <ErrorState message="Failed to load quotations." onRetry={() => q.refetch()} /> : (
          <Table<AdminQuotation>
            keyFn={(r) => r._id}
            loading={q.isLoading}
            rows={items}
            empty={<EmptyState title="No quotations in this view" description="Offers from importers will show up here." icon={FileSignature} />}
            columns={[
              { key: 'ref', header: 'Reference', render: (r) => <span className="font-mono text-xs text-ink-500">{r.referenceNumber}</span> },
              {
                key: 'request', header: 'Request',
                render: (r) => typeof r.request === 'object'
                  ? <Link to={`/admin/orders?requestId=${r.request._id}`} className="font-semibold text-emerald-900 hover:underline">{r.request.title}</Link>
                  : String(r.request),
              },
              {
                key: 'importer', header: 'Importer',
                render: (r) => {
                  const p = typeof r.importerProfile === 'object' ? r.importerProfile : null;
                  const name = p?.businessName ?? String(r.importerProfile ?? '—');
                  return (
                    <div className="flex items-center gap-2.5"><Avatar name={name} size={32} />
                      <div><div className="font-medium">{name}</div>{p?.ratingAverage != null && <div className="inline-flex items-center gap-1 text-xs text-ink-500"><Star className="w-3 h-3 fill-gold-400 text-gold-400" />{p.ratingAverage.toFixed(1)}</div>}</div>
                    </div>
                  );
                },
              },
              { key: 'price', header: 'Price', render: (r) => <span className="font-semibold text-emerald-900">{fmtETB(r.totalPriceETB)}</span> },
              { key: 'delivery', header: 'Delivery', render: (r) => <span className="inline-flex items-center gap-1.5"><Clock className="w-3.5 h-3.5 text-ink-400" />{r.estimatedDeliveryDays}d</span> },
              { key: 'status', header: 'Status', render: (r) => <Badge tone={statusTone[r.status] ?? 'slate'} dot>{humanize(r.status)}</Badge> },
              { key: 'created', header: 'Created', render: (r) => fmtDate(r.createdAt) },
            ]}
          />
        )}
      </Card>
    </div>
  );
}
