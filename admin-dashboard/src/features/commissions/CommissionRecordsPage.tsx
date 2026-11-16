import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Badge } from '@/components/common/Badge';
import { Select } from '@/components/common/Select';
import { EmptyState } from '@/components/common/EmptyState';
import { listCommissionRecords } from '@/api/admin.api';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';
import type { CommissionRecord } from '@/types/admin.types';

const tone = {
  pending: 'amber', invoiced: 'blue', received: 'emerald', waived: 'slate', refunded: 'red',
} as const;

export default function CommissionRecordsPage() {
  const [state, setState] = useState('pending');
  const q = useQuery({
    queryKey: ['commission-records', state],
    queryFn: () => listCommissionRecords({ revenueState: state || undefined, limit: 50 }),
  });
  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-3xl text-emerald-950">Commission records</h1>
        <p className="text-ink-500 mt-1">Immutable per-order fee snapshot. Advance state as invoices settle.</p>
      </div>
      <Card>
        <div className="p-4 w-64">
          <Select label="Revenue state" value={state} onChange={(e) => setState(e.target.value)}>
            <option value="">All</option>
            <option value="pending">Pending</option>
            <option value="invoiced">Invoiced</option>
            <option value="received">Received</option>
            <option value="waived">Waived</option>
            <option value="refunded">Refunded</option>
          </Select>
        </div>
        <Table<CommissionRecord>
          keyFn={(r) => r._id}
          loading={q.isLoading}
          rows={q.data?.items ?? []}
          empty={<EmptyState title="No records in this state" />}
          columns={[
            {
              key: 'order', header: 'Order',
              render: (r) => typeof r.order === 'object' ? r.order.referenceNumber : r.order,
            },
            { key: 'rule', header: 'Rule', render: (r) => <span className="font-mono text-xs">{r.ruleVersion}</span> },
            { key: 'orderVal', header: 'Order value', render: (r) => fmtETB(r.orderValueETB) },
            { key: 'fee', header: 'Fee', render: (r) => fmtETB(r.computedFeeETB) },
            { key: 'payer', header: 'Payer', render: (r) => humanize(r.payer) },
            { key: 'state', header: 'State', render: (r) => <Badge tone={tone[r.revenueState]}>{humanize(r.revenueState)}</Badge> },
            { key: 'created', header: 'Created', render: (r) => fmtDate(r.createdAt) },
          ]}
        />
      </Card>
    </div>
  );
}