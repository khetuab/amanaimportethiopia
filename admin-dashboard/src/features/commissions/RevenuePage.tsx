import { useQuery } from '@tanstack/react-query';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Skeleton } from '@/components/common/Skeleton';
import { getRevenueSummary } from '@/api/admin.api';
import { fmtETB, humanize } from '@/lib/formatters';

export default function RevenuePage() {
  const q = useQuery({ queryKey: ['revenue-summary'], queryFn: getRevenueSummary });
  if (q.isLoading) return <Skeleton className="h-64" />;
  if (q.isError || !q.data) return <div className="text-red-700">Unable to load revenue.</div>;
  const d = q.data;

  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-3xl text-emerald-950">Revenue reconciliation</h1>
        <p className="text-ink-500 mt-1">Earned, invoiced, received — kept strictly separate.</p>
      </div>
      <div className="grid md:grid-cols-3 xl:grid-cols-5 gap-4">
        {(['pending', 'invoiced', 'received', 'waived', 'refunded'] as const).map((k) => (
          <Card key={k}>
            <CardBody>
              <div className="text-sm text-ink-500">{humanize(k)}</div>
              <div className="mt-2 text-2xl font-semibold text-emerald-950">{fmtETB(d[k].total)}</div>
              <div className="text-xs text-ink-400 mt-1">{d[k].count} record(s)</div>
            </CardBody>
          </Card>
        ))}
      </div>
      <Card>
        <CardHeader title="Verified payments" subtitle="Sum of payment records confirmed by admin" />
        <CardBody>
          <div className="text-3xl font-semibold text-emerald-950">{fmtETB(d.received.total)}</div>
          <div className="text-sm text-ink-500">Received commission, verified</div>
        </CardBody>
      </Card>
    </div>
  );
}