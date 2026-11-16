import { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Package, Wallet, Percent, Truck } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SegmentedFilter } from '@/components/pro/FilterBar';
import { CountUp } from '@/components/pro/motion';
import { useOrdersList } from './useOrders';
import { PIPELINE, stageIndex } from '@/lib/orderFlow';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';
import type { Order, OrderStatus } from '@/types/order.types';

const tone: Partial<Record<OrderStatus, 'emerald' | 'gold' | 'red' | 'amber' | 'slate' | 'blue'>> = {
  awaiting_payment_confirmation: 'amber', payment_condition_satisfied: 'blue', processing: 'blue',
  import_shipment_in_progress: 'blue', customs_clearance: 'blue', in_transit: 'blue', ready_for_delivery: 'blue',
  delivered: 'emerald', completed: 'emerald', cancelled: 'slate', disputed: 'red', refund_pending: 'amber', refunded: 'slate',
};

const FILTERS: { value: OrderStatus | ''; label: string }[] = [
  { value: '', label: 'All' }, { value: 'awaiting_payment_confirmation', label: 'Awaiting payment' },
  { value: 'payment_condition_satisfied', label: 'Payment satisfied' }, { value: 'processing', label: 'Processing' },
  { value: 'in_transit', label: 'In transit' }, { value: 'delivered', label: 'Delivered' },
  { value: 'completed', label: 'Completed' }, { value: 'disputed', label: 'Disputed' }, { value: 'cancelled', label: 'Cancelled' },
];

function MiniProgress({ status }: { status: OrderStatus }) {
  const i = stageIndex(status);
  const pct = i < 0 ? 0 : ((i + 1) / PIPELINE.length) * 100;
  const bad = i < 0;
  return (
    <div className="w-28">
      <div className="h-1.5 rounded-full bg-ink-100 overflow-hidden">
        <div className={`h-full rounded-full transition-all duration-700 ${bad ? 'bg-ink-300' : 'bg-gradient-to-r from-emerald-400 to-emerald-600'}`} style={{ width: `${bad ? 100 : pct}%` }} />
      </div>
      <div className="text-[10px] text-ink-400 mt-1">{bad ? 'Off-pipeline' : `Step ${i + 1} of ${PIPELINE.length}`}</div>
    </div>
  );
}

export default function OrdersPage() {
  const [status, setStatus] = useState<OrderStatus | ''>('');
  const nav = useNavigate();
  const q = useOrdersList({ status: status || undefined, limit: 100 });
  const items = q.data?.items ?? [];
  const totals = useMemo(() => ({
    value: items.reduce((s, o) => s + (o.totalPriceETB ?? 0), 0),
    fee: items.reduce((s, o) => s + (o.platformFeeETB ?? 0), 0),
    active: items.filter((o) => stageIndex(o.status) > 0 && stageIndex(o.status) < PIPELINE.length - 1).length,
  }), [items]);

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Order operations" eyebrowIcon={Truck}
        title="Orders"
        subtitle="Every accepted quotation becomes an auditable order. Follow each one from payment to doorstep."
        art="orders"
        stats={[
          { label: 'Orders in view', value: <CountUp value={items.length} />, icon: Package },
          { label: 'In progress', value: <CountUp value={totals.active} />, icon: Truck },
          { label: 'Order value', value: <CountUp value={totals.value} format={fmtETB} />, icon: Wallet },
          { label: 'Platform fees', value: <CountUp value={totals.fee} format={fmtETB} />, icon: Percent },
        ]}
      />

      <FilterBar><SegmentedFilter options={FILTERS} value={status} onChange={setStatus} /></FilterBar>

      <Card className="overflow-hidden">
        {q.isError ? <ErrorState message="Failed to load orders." onRetry={() => q.refetch()} /> : (
          <Table<Order>
            keyFn={(r) => r._id}
            loading={q.isLoading}
            rows={items}
            empty={<EmptyState title="No orders in this view" description="Orders appear here once a buyer accepts a quotation." icon={Package} />}
            onRowClick={(r) => nav(`/admin/orders/${r._id}`)}
            columns={[
              { key: 'ref', header: 'Reference', render: (r) => <Link to={`/admin/orders/${r._id}`} onClick={(e) => e.stopPropagation()} className="font-semibold text-emerald-900 hover:underline">{r.referenceNumber}</Link> },
              { key: 'title', header: 'Item', render: (r) => <div className="max-w-[240px] truncate">{r.snapshot.title}</div> },
              { key: 'importer', header: 'Importer', render: (r) => r.snapshot.importerBusinessName },
              { key: 'total', header: 'Total', render: (r) => <span className="font-semibold">{fmtETB(r.totalPriceETB)}</span> },
              { key: 'fee', header: 'Fee', render: (r) => <span className="text-ink-500">{fmtETB(r.platformFeeETB)}</span> },
              { key: 'progress', header: 'Progress', render: (r) => <MiniProgress status={r.status} /> },
              { key: 'status', header: 'Status', render: (r) => <Badge tone={tone[r.status] ?? 'slate'} dot>{humanize(r.status)}</Badge> },
              { key: 'created', header: 'Created', render: (r) => fmtDate(r.createdAt) },
            ]}
          />
        )}
      </Card>
    </div>
  );
}
