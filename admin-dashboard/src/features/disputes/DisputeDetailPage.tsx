import { useState } from 'react';
import { useParams } from 'react-router-dom';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import {
  Scale, Gavel, FileText, Image as ImageIcon, ExternalLink, MessageSquare, Quote, UserRound, CalendarClock,
  Receipt, Handshake, Store, ShoppingBag, CheckCircle2, Banknote,
} from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { Input, Textarea } from '@/components/common/Input';
import { Skeleton } from '@/components/common/Skeleton';
import { Modal } from '@/components/common/Modal';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { InfoList, InfoRow } from '@/components/pro/InfoList';
import { Stagger, StaggerItem } from '@/components/pro/motion';
import { Avatar } from '@/components/pro/Avatar';
import { useDispute, useResolveDispute } from './useDisputes';
import { fmtDateTime, fmtETB, humanize } from '@/lib/formatters';

const outcomes = [
  { value: 'resolved_buyer_favor', label: "In buyer's favor", hint: 'Buyer is right; importer must make it good.', icon: ShoppingBag },
  { value: 'resolved_importer_favor', label: "In importer's favor", hint: 'Importer fulfilled the agreement.', icon: Store },
  { value: 'resolved_mutual', label: 'Mutual resolution', hint: 'Both sides agree on a middle path.', icon: Handshake },
] as const;

export default function DisputeDetailPage() {
  const { id = '' } = useParams();
  const q = useDispute(id);
  const mut = useResolveDispute(id);
  const [resolveOpen, setResolveOpen] = useState(false);
  const [outcome, setOutcome] = useState<typeof outcomes[number]['value']>('resolved_mutual');
  const [notes, setNotes] = useState('');
  const [refund, setRefund] = useState('');

  if (q.isLoading) return <div className="space-y-5"><Skeleton className="h-64 rounded-[28px]" /><Skeleton className="h-48 rounded-3xl" /></div>;
  if (q.isError || !q.data) return <ErrorState message="Failed to load dispute." onRetry={() => q.refetch()} />;
  const d = q.data;
  const order = typeof d.order === 'object' ? d.order : null;
  const live = d.status === 'open' || d.status === 'under_review';

  return (
    <div className="space-y-6">
      <PageHero
        back={{ to: '/admin/disputes', label: 'All disputes' }}
        eyebrow="Dispute case" eyebrowIcon={Gavel}
        title={humanize(d.reason)}
        art="disputes"
        meta={(
          <>
            <Badge tone={d.status === 'open' ? 'red' : live ? 'amber' : 'emerald'} pulse={d.status === 'open'}>{humanize(d.status)}</Badge>
            {order && <span className="inline-flex items-center gap-1.5"><Receipt className="w-3.5 h-3.5" />Order {order.referenceNumber}</span>}
            <span className="inline-flex items-center gap-1.5"><CalendarClock className="w-3.5 h-3.5" />Opened {fmtDateTime(d.createdAt)}</span>
          </>
        )}
        actions={live ? <Button variant="gold" onClick={() => setResolveOpen(true)}><Gavel className="w-4 h-4" /> Resolve dispute</Button> : undefined}
      />

      <Stagger className="grid lg:grid-cols-3 gap-5" gap={0.08}>
        <StaggerItem className="lg:col-span-2">
          <Card className="h-full">
            <CardHeader icon={Quote} title="What happened" subtitle={`Reported by the ${d.openedByRole}`} />
            <CardBody>
              <div className="relative rounded-3xl bg-gradient-to-br from-ink-50 to-white border border-ink-100 p-6">
                <Quote className="absolute top-4 right-5 w-10 h-10 text-emerald-100" />
                <p className="relative text-ink-800 leading-relaxed whitespace-pre-wrap">{d.description}</p>
              </div>
            </CardBody>
          </Card>
        </StaggerItem>
        <StaggerItem>
          <Card className="h-full">
            <CardHeader icon={UserRound} title="Parties & order" />
            <CardBody className="space-y-4">
              {typeof d.openedBy === 'object' && (
                <div className="flex items-center gap-3">
                  <Avatar name={d.openedBy.fullName} size={44} />
                  <div className="min-w-0"><div className="font-semibold truncate">{d.openedBy.fullName}</div><div className="text-xs text-ink-500 capitalize">{d.openedByRole} · {d.openedBy.email}</div></div>
                </div>
              )}
              <InfoList>
                <InfoRow label="Opened" value={fmtDateTime(d.createdAt)} />
                {order && <InfoRow label="Order total" value={fmtETB(order.totalPriceETB)} bold />}
                {order && <InfoRow label="Order status" value={humanize(order.status)} />}
              </InfoList>
            </CardBody>
          </Card>
        </StaggerItem>
      </Stagger>

      {d.evidence.length > 0 && (
        <Card>
          <CardHeader icon={FileText} title="Evidence" subtitle={`${d.evidence.length} file(s)`} />
          <CardBody>
            <Stagger className="grid md:grid-cols-2 xl:grid-cols-3 gap-4" gap={0.06}>
              {d.evidence.map((e, i) => {
                const Icon = e.mimeType?.startsWith('image/') ? ImageIcon : FileText;
                return (
                  <StaggerItem key={i}>
                    <a href={e.url} target="_blank" rel="noreferrer" className="group flex items-center gap-4 rounded-2xl border border-ink-200 p-4 bg-white hover:border-emerald-300 hover:shadow-card hover:-translate-y-0.5 transition-all">
                      <div className="w-12 h-12 shrink-0 rounded-2xl bg-gradient-to-br from-emerald-50 to-emerald-100 text-emerald-700 flex items-center justify-center group-hover:from-emerald-500 group-hover:to-emerald-700 group-hover:text-white transition-all"><Icon className="w-6 h-6" /></div>
                      <div className="min-w-0 flex-1"><div className="text-sm font-semibold truncate">{e.description || `Evidence ${i + 1}`}</div><div className="text-xs text-ink-500">{e.mimeType}</div></div>
                      <ExternalLink className="w-4 h-4 text-ink-300 group-hover:text-emerald-600" />
                    </a>
                  </StaggerItem>
                );
              })}
            </Stagger>
          </CardBody>
        </Card>
      )}

      {d.messages.length > 0 && (
        <Card>
          <CardHeader icon={MessageSquare} title="Messages" subtitle={`${d.messages.length} in thread`} />
          <CardBody className="space-y-3">
            {d.messages.map((m, i) => {
              const right = m.authorRole === 'importer';
              return (
                <motion.div key={i} initial={{ opacity: 0, y: 10 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: Math.min(i, 5) * 0.05 }}
                  className={`flex gap-2.5 ${right ? 'flex-row-reverse' : ''}`}>
                  <Avatar name={m.authorRole} size={32} />
                  <div className={`max-w-[80%] rounded-2xl px-4 py-2.5 text-sm ${m.authorRole === 'admin' ? 'bg-emerald-50 border border-emerald-200' : right ? 'bg-ink-100' : 'bg-white border border-ink-200'}`}>
                    <div className="text-[11px] text-ink-500 mb-0.5">{humanize(m.authorRole)} · {fmtDateTime(m.at)}</div>
                    <div className="leading-relaxed">{m.body}</div>
                  </div>
                </motion.div>
              );
            })}
          </CardBody>
        </Card>
      )}

      {d.resolution && (
        <Card className="overflow-hidden border-emerald-200">
          <div className="bg-gradient-to-r from-emerald-600 to-emerald-800 px-6 py-4 text-white flex items-center gap-3">
            <CheckCircle2 className="w-6 h-6" /><div><div className="font-semibold">Resolved</div><div className="text-xs text-emerald-100/80">{humanize(d.resolution.outcome)}</div></div>
          </div>
          <CardBody>
            <InfoList>
              <InfoRow label="Outcome" value={humanize(d.resolution.outcome)} />
              <InfoRow label="Resolved at" value={fmtDateTime(d.resolution.resolvedAt)} />
              {d.resolution.refundPromisedETB != null && <InfoRow icon={Banknote} label="Refund promised" value={fmtETB(d.resolution.refundPromisedETB)} bold />}
              {d.resolution.notes && <InfoRow label="Notes" value={d.resolution.notes} />}
            </InfoList>
          </CardBody>
        </Card>
      )}

      <Modal
        open={resolveOpen} onClose={() => setResolveOpen(false)} title="Resolve dispute" subtitle="Your decision is final and audited." icon={Scale} width="max-w-xl"
        footer={
          <>
            <Button variant="ghost" onClick={() => setResolveOpen(false)}>Cancel</Button>
            <Button loading={mut.isPending} onClick={async () => {
              await mut.mutateAsync({ outcome, notes, refundPromisedETB: refund ? Number(refund) : undefined });
              toast.success('Dispute resolved');
              setResolveOpen(false);
            }}>Resolve</Button>
          </>
        }
      >
        <div className="space-y-5">
          <div>
            <span className="block text-sm font-medium text-ink-700 mb-2">Outcome</span>
            <div className="grid gap-2.5">
              {outcomes.map((o) => {
                const on = outcome === o.value;
                return (
                  <button key={o.value} type="button" onClick={() => setOutcome(o.value)}
                    className={`relative flex items-center gap-3.5 text-left rounded-2xl border px-4 py-3.5 transition-all ${on ? 'border-emerald-500 bg-emerald-50 shadow-[0_0_0_4px_rgba(16,185,129,0.12)]' : 'border-ink-200 hover:border-emerald-300'}`}>
                    <span className={`w-10 h-10 rounded-xl flex items-center justify-center transition-colors ${on ? 'bg-emerald-600 text-white' : 'bg-ink-100 text-ink-500'}`}><o.icon className="w-5 h-5" /></span>
                    <span className="flex-1"><span className="block text-sm font-semibold text-ink-900">{o.label}</span><span className="block text-xs text-ink-500">{o.hint}</span></span>
                    <span className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${on ? 'border-emerald-600' : 'border-ink-300'}`}>{on && <motion.span layoutId="outcome-dot" className="w-2.5 h-2.5 rounded-full bg-emerald-600" />}</span>
                  </button>
                );
              })}
            </div>
          </div>
          <Input label="Refund promised (ETB)" type="number" value={refund} onChange={(e) => setRefund(e.target.value)} placeholder="Optional" icon={<Banknote />} />
          <Textarea label="Notes" value={notes} onChange={(e) => setNotes(e.target.value)} className="min-h-[90px]" />
        </div>
      </Modal>
    </div>
  );
}
