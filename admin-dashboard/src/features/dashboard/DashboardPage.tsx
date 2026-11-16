import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import {
  Package, CreditCard, AlertTriangle, TrendingUp, BadgeCheck, Landmark, ArrowRight, CheckCircle2,
  Star, Crown, Send, FileSignature, ClipboardList, Sparkles,
} from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Skeleton } from '@/components/common/Skeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { Button } from '@/components/common/Button';
import { RequestsChart } from '@/components/charts/RequestsChart';
import { DisputesChart } from '@/components/charts/DisputesChart';
import { PageHero } from '@/components/pro/PageHero';
import { StatCard } from '@/components/pro/StatCard';
import { TradeScene } from '@/components/pro/Art';
import { CountUp, Reveal, Stagger, StaggerItem, ease } from '@/components/pro/motion';
import { Avatar } from '@/components/pro/Avatar';
import { useAuth } from '@/features/auth/useAuth';
import { getReportsSummary } from '@/api/admin.api';
import { fmtETB, humanize } from '@/lib/formatters';

const greeting = () => {
  const h = new Date().getHours();
  return h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
};

const STATUS_COLORS: Record<string, string> = {
  approved: 'bg-emerald-500', pending: 'bg-amber-400', rejected: 'bg-red-500',
  suspended: 'bg-ink-700', expired: 'bg-ink-300', draft: 'bg-sky-400',
};
const REVENUE_META = {
  pending: { label: 'Pending', bar: 'bg-amber-400', dot: 'bg-amber-400' },
  invoiced: { label: 'Invoiced', bar: 'bg-sky-500', dot: 'bg-sky-500' },
  received: { label: 'Received', bar: 'bg-emerald-500', dot: 'bg-emerald-500' },
  waived: { label: 'Waived', bar: 'bg-ink-400', dot: 'bg-ink-400' },
  refunded: { label: 'Refunded', bar: 'bg-rose-400', dot: 'bg-rose-400' },
} as const;

export default function DashboardPage() {
  const q = useQuery({ queryKey: ['reports', 'summary'], queryFn: getReportsSummary });
  const { user } = useAuth();

  if (q.isLoading) return (
    <div className="space-y-6">
      <Skeleton className="h-64 rounded-[28px]" />
      <div className="grid md:grid-cols-3 gap-4">{[0, 1, 2].map((i) => <Skeleton key={i} className="h-28 rounded-3xl" />)}</div>
      <div className="grid md:grid-cols-4 gap-4">{[0, 1, 2, 3].map((i) => <Skeleton key={i} className="h-36 rounded-3xl" />)}</div>
      <div className="grid md:grid-cols-2 gap-4"><Skeleton className="h-80 rounded-3xl" /><Skeleton className="h-80 rounded-3xl" /></div>
    </div>
  );
  if (q.isError || !q.data) return <ErrorState message="Unable to load reports." onRetry={() => q.refetch()} />;

  const d = q.data;
  const statusData = Object.entries(d.requests.byStatus).map(([k, v]) => ({ name: humanize(k), value: v }));
  const disputeData = Object.entries(d.disputes.byStatus).map(([k, v]) => ({ name: humanize(k), value: v }));
  const first = user?.fullName?.split(' ')[0] ?? 'there';
  const pendingImporters = d.importers.byStatus?.pending ?? 0;

  const revTotal = (Object.keys(REVENUE_META) as (keyof typeof REVENUE_META)[]).reduce((s, k) => s + d.revenue[k].total, 0);
  const importerTotal = Object.values(d.importers.byStatus).reduce((s, v) => s + v, 0);
  const funnel = [
    { label: 'Requests', value: d.conversions.requests, icon: ClipboardList, grad: 'from-emerald-300 to-emerald-500' },
    { label: 'Quotations', value: d.conversions.quotations, icon: FileSignature, grad: 'from-emerald-500 to-emerald-700' },
    { label: 'Orders', value: d.conversions.orders, icon: Package, grad: 'from-emerald-700 to-emerald-900' },
  ];
  const funnelMax = Math.max(...funnel.map((f) => f.value), 1);
  const topMax = Math.max(...d.importers.top.map((t) => t.completedOrdersCount), 1);

  return (
    <div className="space-y-7">
      <PageHero
        eyebrow="Operations overview"
        title={<>{greeting()}, <span className="text-gold-300">{first}</span>.</>}
        subtitle="Here is everything that needs your eyes today — verifications, disputes and money in motion — all in one live view."
        art={<TradeScene className="w-[400px] h-auto" />}
        actions={(
          <>
            <Link to="/admin/importers"><Button variant="light">Review importers <ArrowRight className="w-4 h-4" /></Button></Link>
            <Link to="/admin/disputes"><Button variant="glass">Open disputes</Button></Link>
          </>
        )}
        stats={[
          { label: 'Requests', value: <CountUp value={d.conversions.requests} />, icon: ClipboardList },
          { label: 'Quotations', value: <CountUp value={d.conversions.quotations} />, icon: Send },
          { label: 'Orders', value: <CountUp value={d.conversions.orders} />, icon: Package },
          { label: 'Avg quotes / request', value: <CountUp value={d.conversions.avgQuotationsPerRequest} format={(n) => n.toFixed(1)} />, icon: Sparkles },
        ]}
      />

      {/* attention center */}
      <section>
        <Reveal><h2 className="text-sm font-semibold uppercase tracking-wider text-ink-500 mb-3">Needs your attention</h2></Reveal>
        <Stagger className="grid md:grid-cols-3 gap-4" gap={0.08}>
          <StaggerItem><Attention to="/admin/importers" icon={BadgeCheck} count={pendingImporters} label="Importers awaiting verification" clear="No verifications waiting" /></StaggerItem>
          <StaggerItem><Attention to="/admin/disputes" icon={AlertTriangle} count={d.disputes.open} label="Open disputes" clear="No open disputes" tone="red" /></StaggerItem>
          <StaggerItem><Attention to="/admin/commissions/reconciliation" icon={Landmark} count={d.revenue.pending.count} label="Commissions pending" sub={fmtETB(d.revenue.pending.total)} clear="No commissions pending" tone="gold" /></StaggerItem>
        </Stagger>
      </section>

      {/* KPIs */}
      <Stagger className="grid md:grid-cols-2 xl:grid-cols-4 gap-4" gap={0.07} delay={0.1}>
        <StaggerItem><StatCard icon={Package} label="Total requests" value={d.requests.total} sub={`${d.requests.byStatus['receiving_offers'] ?? 0} receiving offers`} tone="emerald" to="/admin/requests" /></StaggerItem>
        <StaggerItem><StatCard icon={CreditCard} label="Verified payments" value={d.revenue.verifiedPayments.total} format={fmtETB} sub={`${d.revenue.verifiedPayments.count} transactions`} tone="gold" to="/admin/payments" /></StaggerItem>
        <StaggerItem><StatCard icon={AlertTriangle} label="Open disputes" value={d.disputes.open} sub={`${d.disputes.total} total`} tone="red" to="/admin/disputes" pulse={d.disputes.open > 0} /></StaggerItem>
        <StaggerItem><StatCard icon={TrendingUp} label="Request → order" value={d.conversions.requestToOrderRate} format={(n) => `${Math.round(n)}%`} sub={`${d.conversions.orders} orders · ${d.conversions.quotations} quotes`} tone="blue" to="/admin/orders" /></StaggerItem>
      </Stagger>

      {/* charts */}
      <div className="grid lg:grid-cols-[1.35fr_1fr] gap-5">
        <Reveal>
          <Card className="h-full">
            <CardHeader icon={ClipboardList} title="Requests by status" subtitle="Live pipeline distribution" />
            <CardBody><RequestsChart data={statusData} /></CardBody>
          </Card>
        </Reveal>
        <Reveal delay={0.08}>
          <Card className="h-full">
            <CardHeader icon={AlertTriangle} title="Disputes" subtitle="By state" />
            <CardBody><DisputesChart data={disputeData} /></CardBody>
          </Card>
        </Reveal>
      </div>

      {/* funnel + revenue */}
      <div className="grid lg:grid-cols-2 gap-5">
        <Reveal>
          <Card className="h-full">
            <CardHeader icon={TrendingUp} title="Marketplace funnel" subtitle="From request to accepted order" />
            <CardBody className="space-y-4">
              {funnel.map((f, i) => (
                <div key={f.label}>
                  <div className="flex items-center justify-between text-sm mb-1.5">
                    <span className="flex items-center gap-2 text-ink-700"><f.icon className="w-4 h-4 text-emerald-600" />{f.label}</span>
                    <span className="font-semibold text-ink-900"><CountUp value={f.value} /></span>
                  </div>
                  <div className="h-9 rounded-xl bg-ink-100 overflow-hidden">
                    <motion.div className={`h-full rounded-xl bg-gradient-to-r ${f.grad}`} initial={{ width: 0 }} whileInView={{ width: `${Math.max((f.value / funnelMax) * 100, 3)}%` }}
                      viewport={{ once: true }} transition={{ duration: 1.1, ease, delay: i * 0.15 }} />
                  </div>
                </div>
              ))}
              <div className="grid grid-cols-2 gap-3 pt-2">
                <div className="rounded-2xl bg-emerald-50 p-3.5 text-center"><div className="text-xl font-semibold text-emerald-900"><CountUp value={d.conversions.requestToQuoteRate} format={(n) => `${Math.round(n)}%`} /></div><div className="text-xs text-emerald-800/70">Request → quote</div></div>
                <div className="rounded-2xl bg-emerald-50 p-3.5 text-center"><div className="text-xl font-semibold text-emerald-900"><CountUp value={d.conversions.requestToOrderRate} format={(n) => `${Math.round(n)}%`} /></div><div className="text-xs text-emerald-800/70">Request → order</div></div>
              </div>
            </CardBody>
          </Card>
        </Reveal>

        <Reveal delay={0.08}>
          <Card className="h-full">
            <CardHeader icon={Landmark} title="Revenue pipeline" subtitle="Commission records by state" right={<Link to="/admin/commissions/reconciliation" className="text-sm text-emerald-700 hover:text-emerald-900 inline-flex items-center gap-1">Reconcile <ArrowRight className="w-4 h-4" /></Link>} />
            <CardBody>
              <div className="flex h-5 rounded-full overflow-hidden bg-ink-100 mb-6">
                {(Object.keys(REVENUE_META) as (keyof typeof REVENUE_META)[]).map((k, i) => {
                  const pct = revTotal > 0 ? (d.revenue[k].total / revTotal) * 100 : 0;
                  return <motion.div key={k} className={REVENUE_META[k].bar} initial={{ width: 0 }} whileInView={{ width: `${pct}%` }} viewport={{ once: true }} transition={{ duration: 1, ease, delay: i * 0.1 }} title={REVENUE_META[k].label} />;
                })}
              </div>
              <div className="space-y-3">
                {(Object.keys(REVENUE_META) as (keyof typeof REVENUE_META)[]).map((k) => (
                  <div key={k} className="flex items-center gap-3 text-sm">
                    <span className={`w-2.5 h-2.5 rounded-full ${REVENUE_META[k].dot}`} />
                    <span className="flex-1 text-ink-600">{REVENUE_META[k].label}<span className="text-ink-400"> · {d.revenue[k].count}</span></span>
                    <span className="font-semibold text-ink-900"><CountUp value={d.revenue[k].total} format={fmtETB} /></span>
                  </div>
                ))}
              </div>
            </CardBody>
          </Card>
        </Reveal>
      </div>

      {/* importers */}
      <div className="grid lg:grid-cols-[1.35fr_1fr] gap-5">
        <Reveal>
          <Card className="h-full">
            <CardHeader icon={Crown} title="Top importers" subtitle="By completed orders" />
            <CardBody>
              {d.importers.top.length === 0 ? (
                <div className="text-sm text-ink-500 py-8 text-center">No completed orders yet.</div>
              ) : (
                <ol className="space-y-4">
                  {d.importers.top.slice(0, 5).map((it, i) => (
                    <li key={it._id} className="flex items-center gap-4">
                      <div className={`w-8 h-8 shrink-0 rounded-full flex items-center justify-center text-sm font-bold ${i === 0 ? 'bg-gradient-to-br from-gold-300 to-gold-500 text-ink-900 shadow-md' : 'bg-ink-100 text-ink-600'}`}>
                        {i === 0 ? <Crown className="w-4 h-4" /> : i + 1}
                      </div>
                      <Avatar name={it.businessName} size={38} />
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center justify-between gap-3">
                          <span className="font-medium text-ink-900 truncate">{it.businessName}</span>
                          <span className="inline-flex items-center gap-1 text-sm text-ink-600"><Star className="w-3.5 h-3.5 fill-gold-400 text-gold-400" />{it.ratingAverage.toFixed(1)}</span>
                        </div>
                        <div className="mt-1.5 h-2 rounded-full bg-ink-100 overflow-hidden">
                          <motion.div className="h-full rounded-full bg-gradient-to-r from-emerald-400 to-emerald-600" initial={{ width: 0 }} whileInView={{ width: `${(it.completedOrdersCount / topMax) * 100}%` }} viewport={{ once: true }} transition={{ duration: 0.9, ease, delay: i * 0.08 }} />
                        </div>
                      </div>
                      <div className="text-right shrink-0 w-14"><div className="font-semibold text-ink-900">{it.completedOrdersCount}</div><div className="text-[11px] text-ink-400">orders</div></div>
                    </li>
                  ))}
                </ol>
              )}
            </CardBody>
          </Card>
        </Reveal>

        <Reveal delay={0.08}>
          <Card className="h-full">
            <CardHeader icon={BadgeCheck} title="Importer verification" subtitle={`${importerTotal} importers`} />
            <CardBody>
              <div className="flex h-4 rounded-full overflow-hidden bg-ink-100 mb-6">
                {Object.entries(d.importers.byStatus).map(([k, v], i) => (
                  <motion.div key={k} className={STATUS_COLORS[k] ?? 'bg-ink-400'} initial={{ width: 0 }} whileInView={{ width: `${importerTotal ? (v / importerTotal) * 100 : 0}%` }} viewport={{ once: true }} transition={{ duration: 1, ease, delay: i * 0.1 }} />
                ))}
              </div>
              <div className="space-y-3">
                {Object.entries(d.importers.byStatus).map(([k, v]) => (
                  <div key={k} className="flex items-center gap-3 text-sm">
                    <span className={`w-2.5 h-2.5 rounded-full ${STATUS_COLORS[k] ?? 'bg-ink-400'}`} />
                    <span className="flex-1 text-ink-600">{humanize(k)}</span>
                    <span className="font-semibold text-ink-900 tabular-nums">{v}</span>
                  </div>
                ))}
              </div>
            </CardBody>
          </Card>
        </Reveal>
      </div>
    </div>
  );
}

function Attention({
  to, icon: Icon, count, label, clear, sub, tone = 'emerald',
}: { to: string; icon: LucideIcon; count: number; label: string; clear: string; sub?: string; tone?: 'emerald' | 'red' | 'gold' }) {
  const ok = count === 0;
  const ring = ok ? 'border-ink-200/70 bg-white' : tone === 'red' ? 'border-red-200 bg-gradient-to-br from-red-50 to-white' : tone === 'gold' ? 'border-amber-200 bg-gradient-to-br from-amber-50 to-white' : 'border-emerald-200 bg-gradient-to-br from-emerald-50 to-white';
  const chip = ok ? 'bg-emerald-50 text-emerald-600' : tone === 'red' ? 'bg-red-600 text-white' : tone === 'gold' ? 'bg-amber-500 text-white' : 'bg-emerald-600 text-white';
  return (
    <Link to={to} className={`group relative flex items-center gap-4 p-5 rounded-3xl border shadow-card transition-all hover:-translate-y-1 hover:shadow-[0_18px_40px_-18px_rgba(2,44,34,0.35)] ${ring}`}>
      <div className="relative shrink-0">
        {!ok && <span className="absolute inset-0 rounded-2xl bg-current opacity-30 animate-ping-slow text-red-400" />}
        <div className={`relative w-12 h-12 rounded-2xl flex items-center justify-center ${chip}`}>{ok ? <CheckCircle2 className="w-6 h-6" /> : <Icon className="w-6 h-6" />}</div>
      </div>
      <div className="min-w-0 flex-1">
        {ok ? <div className="text-sm font-medium text-ink-700">{clear}</div> : (
          <>
            <div className="text-3xl font-semibold text-ink-900 leading-none"><CountUp value={count} /></div>
            <div className="text-sm text-ink-600 mt-1.5 truncate">{label}</div>
            {sub && <div className="text-xs text-ink-400 mt-0.5 truncate">{sub}</div>}
          </>
        )}
        {ok && <div className="text-xs text-emerald-600 mt-0.5">All clear</div>}
      </div>
      <ArrowRight className="w-5 h-5 text-ink-300 group-hover:text-emerald-600 group-hover:translate-x-1 transition-all" />
    </Link>
  );
}
