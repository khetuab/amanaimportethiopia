import { useEffect, useRef, useState } from 'react';
import { useParams } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import {
  MessageSquare, Send, ShieldCheck, Package, MapPin, Wrench, Undo2, Building2, Mail, Phone, Receipt,
  ScrollText, ArrowRight, Ban, CheckCircle2, Hash, CalendarClock, UserRound, Store,
} from 'lucide-react';
import { toast } from 'sonner';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { Textarea } from '@/components/common/Input';
import { Skeleton } from '@/components/common/Skeleton';
import { Modal } from '@/components/common/Modal';
import { ErrorState } from '@/components/common/ErrorState';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { PageHero } from '@/components/pro/PageHero';
import { InfoList, InfoRow } from '@/components/pro/InfoList';
import { Stepper } from '@/components/pro/Stepper';
import { Timeline } from '@/components/pro/Timeline';
import { Avatar } from '@/components/pro/Avatar';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { useOrder, useTransitionOrder } from './useOrders';
import { getOrderMessages, adminSendOrderMessage } from '@/api/orders.api';
import { PIPELINE, SIDE_STATES, stageIndex } from '@/lib/orderFlow';
import { fmtDateTime, fmtETB, humanize } from '@/lib/formatters';
import type { OrderStatus } from '@/types/order.types';

const allowedNext: Partial<Record<OrderStatus, OrderStatus[]>> = {
  awaiting_payment_confirmation: ['payment_condition_satisfied', 'cancelled'],
  payment_condition_satisfied: ['processing', 'cancelled', 'disputed'],
  processing: ['import_shipment_in_progress', 'disputed', 'cancelled'],
  import_shipment_in_progress: ['customs_clearance', 'in_transit', 'disputed'],
  customs_clearance: ['in_transit', 'disputed'],
  in_transit: ['ready_for_delivery', 'disputed'],
  ready_for_delivery: ['delivered', 'disputed'],
  delivered: ['completed', 'disputed'],
  disputed: ['processing', 'refund_pending', 'cancelled'],
  refund_pending: ['refunded'],
};

export default function OrderDetailPage() {
  const { id = '' } = useParams();
  const q = useOrder(id);
  const transition = useTransitionOrder(id);
  const [chatOpen, setChatOpen] = useState(false);
  const [confirm, setConfirm] = useState<OrderStatus | null>(null);
  const [note, setNote] = useState('');

  if (q.isLoading) return <div className="space-y-5"><Skeleton className="h-72 rounded-[28px]" /><Skeleton className="h-36 rounded-3xl" /><Skeleton className="h-80 rounded-3xl" /></div>;
  if (q.isError || !q.data) return <ErrorState message="Failed to load order." onRetry={() => q.refetch()} />;
  const o = q.data;
  const next = allowedNext[o.status] ?? [];
  const idx = stageIndex(o.status);
  const side = SIDE_STATES[o.status];
  const lastPipelineIdx = (() => {
    if (idx >= 0) return idx;
    // for off-pipeline states, show how far the order got
    for (let i = o.statusHistory.length - 1; i >= 0; i--) { const k = stageIndex(o.statusHistory[i].to as OrderStatus); if (k >= 0) return k; }
    return 0;
  })();

  return (
    <div className="space-y-6">
      <PageHero
        back={{ to: '/admin/orders', label: 'All orders' }}
        eyebrow="Order" eyebrowIcon={Package}
        title={o.referenceNumber}
        subtitle={o.snapshot.title}
        art="orders"
        meta={(
          <>
            <Badge tone={side ? (side.tone === 'red' ? 'red' : side.tone) : o.status === 'completed' || o.status === 'delivered' ? 'emerald' : 'blue'} pulse={!side && o.status !== 'completed'}>{humanize(o.status)}</Badge>
            <span className="font-semibold text-white text-base">{fmtETB(o.totalPriceETB)}</span>
            <span className="inline-flex items-center gap-1.5"><Store className="w-3.5 h-3.5" />{o.snapshot.importerBusinessName}</span>
          </>
        )}
        actions={(
          <>
            <Button variant="glass" onClick={() => setChatOpen(true)}><MessageSquare className="w-4 h-4" /> Conversation</Button>
            {next.map((to) => (
              <Button key={to} variant={to === 'cancelled' ? 'danger' : 'gold'} onClick={() => setConfirm(to)}>
                {to === 'cancelled' ? <Ban className="w-4 h-4" /> : <ArrowRight className="w-4 h-4" />}{humanize(to)}
              </Button>
            ))}
          </>
        )}
      />

      <Card>
        <CardHeader icon={Package} title="Fulfilment pipeline" subtitle={side ? side.label : `Step ${Math.max(idx, 0) + 1} of ${PIPELINE.length}`} />
        <CardBody className="space-y-5">
          <Stepper steps={PIPELINE.map((p) => ({ key: p.key, label: p.label, icon: p.icon }))} current={lastPipelineIdx} failed={!!side && side.tone === 'red'} completed={o.status === 'completed'} />
          {side && (
            <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
              className={`flex items-start gap-3 rounded-2xl px-4 py-3.5 text-sm ring-1 ${side.tone === 'red' ? 'bg-red-50 text-red-800 ring-red-200' : side.tone === 'amber' ? 'bg-amber-50 text-amber-800 ring-amber-200' : 'bg-ink-100 text-ink-700 ring-ink-200'}`}>
              <side.icon className="w-5 h-5 shrink-0 mt-0.5" /><div><b>{side.label}.</b> {side.text}</div>
            </motion.div>
          )}
        </CardBody>
      </Card>

      <Stagger className="grid lg:grid-cols-3 gap-5" gap={0.08}>
        <StaggerItem className="lg:col-span-2">
          <Card className="h-full">
            <CardHeader icon={ScrollText} title="Agreed terms" />
            <CardBody className="space-y-6">
              <InfoList>
                <InfoRow icon={Package} label="Item" value={o.snapshot.title} />
                <InfoRow icon={Hash} label="Quantity" value={`${o.snapshot.quantity} ${o.snapshot.unitOfMeasurement}`} />
                <InfoRow icon={MapPin} label="Delivery city" value={o.snapshot.deliveryCity} />
                <InfoRow icon={Wrench} label="Product condition" value={humanize(o.snapshot.productCondition)} />
                <InfoRow icon={ShieldCheck} label="Warranty" value={o.snapshot.warrantyOffered || '—'} />
                <InfoRow icon={Undo2} label="Return policy" value={o.snapshot.returnPolicy || '—'} />
                <InfoRow icon={Building2} label="Importer" value={o.snapshot.importerBusinessName} />
              </InfoList>

              <div className="rounded-3xl bg-gradient-to-br from-emerald-50 to-white border border-emerald-100 p-5">
                <div className="flex items-center gap-2 text-sm font-semibold text-emerald-900 mb-3"><Receipt className="w-4 h-4" /> Cost breakdown</div>
                <div className="space-y-2">
                  {o.snapshot.itemizedCosts.map((c, i) => (
                    <div key={i} className="flex justify-between text-sm text-ink-700"><span>{c.label}</span><span className="font-medium tabular-nums">{fmtETB(c.amountETB)}</span></div>
                  ))}
                </div>
                <div className="mt-4 pt-4 border-t border-emerald-200/70 flex items-end justify-between">
                  <span className="text-sm text-emerald-900 font-medium">Total</span>
                  <span className="text-3xl font-semibold text-emerald-950"><CountUp value={o.totalPriceETB} format={fmtETB} /></span>
                </div>
                <div className="mt-1 flex justify-between text-xs text-ink-500"><span>Platform fee ({o.platformFeePayer})</span><span>{fmtETB(o.platformFeeETB)}</span></div>
              </div>
            </CardBody>
          </Card>
        </StaggerItem>

        <StaggerItem>
          <Card className="h-full">
            <CardHeader icon={UserRound} title="Contacts" />
            <CardBody className="space-y-5">
              {o.buyerInfo && <Contact role="Buyer" icon={UserRound} p={o.buyerInfo} />}
              {o.buyerInfo && o.importerInfo && <div className="h-px bg-ink-100" />}
              {o.importerInfo && <Contact role="Importer" icon={Store} p={o.importerInfo} />}
            </CardBody>
          </Card>
        </StaggerItem>
      </Stagger>

      <Card>
        <CardHeader icon={CalendarClock} title="Status history" subtitle={`${o.statusHistory.length} events`} />
        <CardBody>
          <Timeline items={o.statusHistory.map((h, i) => ({
            key: String(i), title: humanize(h.to), meta: `${fmtDateTime(h.at)} · ${humanize(h.actorRole ?? '')}`, body: h.note,
            tone: h.to === 'cancelled' || h.to === 'disputed' ? 'red' : h.to === 'completed' || h.to === 'delivered' ? 'emerald' : 'blue',
            icon: h.to === 'completed' ? CheckCircle2 : undefined,
          }))} />
        </CardBody>
      </Card>

      <Modal open={chatOpen} onClose={() => setChatOpen(false)} title="Order conversation" subtitle={o.referenceNumber} icon={MessageSquare} width="max-w-2xl">
        <ConversationView orderId={id} />
      </Modal>

      <ConfirmDialog
        open={!!confirm}
        onCancel={() => { setConfirm(null); setNote(''); }}
        onConfirm={async () => {
          if (!confirm) return;
          await transition.mutateAsync({ to: confirm, note });
          toast.success('Order transitioned');
          setConfirm(null); setNote('');
        }}
        title={`Transition to ${confirm ? humanize(confirm) : ''}?`}
        description={
          <div className="space-y-3">
            <p>This action is recorded in the audit log.</p>
            <Textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Note (optional)…" className="min-h-[90px]" />
          </div>
        }
        destructive={confirm === 'cancelled'}
        confirmLabel="Confirm"
      />
    </div>
  );
}

function Contact({ role, icon: Icon, p }: { role: string; icon: React.ComponentType<{ className?: string }>; p: { fullName: string; email: string; phone: string } }) {
  return (
    <div>
      <div className="flex items-center gap-1.5 text-[11px] uppercase tracking-wider text-ink-400 mb-2"><Icon className="w-3.5 h-3.5" />{role}</div>
      <div className="flex items-center gap-3">
        <Avatar name={p.fullName} size={44} />
        <div className="min-w-0">
          <div className="font-semibold text-ink-900 truncate">{p.fullName}</div>
          <a href={`mailto:${p.email}`} className="flex items-center gap-1.5 text-sm text-ink-500 hover:text-emerald-700 truncate"><Mail className="w-3.5 h-3.5 shrink-0" />{p.email}</a>
          <a href={`tel:${p.phone}`} className="flex items-center gap-1.5 text-sm text-ink-500 hover:text-emerald-700"><Phone className="w-3.5 h-3.5 shrink-0" />{p.phone}</a>
        </div>
      </div>
    </div>
  );
}

function ConversationView({ orderId }: { orderId: string }) {
  const qc = useQueryClient();
  const q = useQuery({ queryKey: ['order-messages', orderId], queryFn: () => getOrderMessages(orderId) });
  const [body, setBody] = useState('');
  const endRef = useRef<HTMLDivElement>(null);

  const send = useMutation({
    mutationFn: () => adminSendOrderMessage(orderId, body.trim()),
    onSuccess: () => {
      setBody('');
      qc.invalidateQueries({ queryKey: ['order-messages', orderId] });
      toast.success('Message sent');
    },
  });

  const count = q.data?.messages.length ?? 0;
  useEffect(() => { endRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' }); }, [count]);

  if (q.isLoading) return <Skeleton className="h-40" />;
  const failed = q.isError || !q.data;

  return (
    <div className="flex flex-col">
      <div className="space-y-3 max-h-[50vh] overflow-y-auto pr-2 mb-4 scrollbar-thin rounded-2xl bg-ink-50/70 p-4">
        {(failed || count === 0) && (
          <div className="text-sm text-ink-500 text-center py-8">
            {failed ? 'No conversation yet. You can still send the first message below.' : 'No messages exchanged. Send a message to start the conversation.'}
          </div>
        )}
        <AnimatePresence initial={false}>
          {(q.data?.messages ?? []).map((m) => {
            const isAdmin = m.senderRole === 'admin';
            const isBuyer = m.senderRole === 'buyer';
            if (isAdmin) {
              return (
                <motion.div key={m._id} layout initial={{ opacity: 0, y: 10, scale: 0.97 }} animate={{ opacity: 1, y: 0, scale: 1 }}
                  className="rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white px-4 py-3 text-sm shadow-sm">
                  <div className="text-[11px] text-emerald-800 font-semibold mb-1 inline-flex items-center gap-1.5"><ShieldCheck className="w-3.5 h-3.5" /> EthioMarket Support · {fmtDateTime(m.createdAt)}</div>
                  <div className="text-emerald-950 leading-relaxed">{m.body}</div>
                </motion.div>
              );
            }
            return (
              <motion.div key={m._id} layout initial={{ opacity: 0, y: 10, x: isBuyer ? -10 : 10 }} animate={{ opacity: 1, y: 0, x: 0 }}
                className={`flex gap-2.5 ${isBuyer ? '' : 'flex-row-reverse'}`}>
                <Avatar name={m.sender?.fullName ?? m.senderRole} size={30} />
                <div className={`max-w-[78%] rounded-2xl px-3.5 py-2.5 text-sm shadow-sm ${isBuyer ? 'bg-white text-ink-900 rounded-tl-md border border-ink-100' : 'bg-gradient-to-br from-emerald-600 to-emerald-800 text-white rounded-tr-md'}`}>
                  <div className={`text-[11px] mb-0.5 ${isBuyer ? 'text-ink-500' : 'text-emerald-100/80'}`}>{m.sender?.fullName ?? humanize(m.senderRole)} · {fmtDateTime(m.createdAt)}</div>
                  <div className="leading-relaxed">{m.body}</div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
        <div ref={endRef} />
      </div>

      <div className="flex items-end gap-2">
        <div className="flex-1 min-w-0"><Textarea value={body} onChange={(e) => setBody(e.target.value)} rows={2} className="resize-none"
          placeholder="Write a message to both parties as EthioMarket Support…"
          onKeyDown={(e) => { if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) { e.preventDefault(); if (body.trim() && !send.isPending) send.mutate(); } }} /></div>
        <Button loading={send.isPending} disabled={!body.trim() || send.isPending} onClick={() => send.mutate()} className="h-[60px] w-14 !px-0" aria-label="Send message"><Send className="w-5 h-5" /></Button>
      </div>
      <div className="mt-2.5 text-xs text-ink-500 text-center">
        Messages sent from here appear to both parties as <b>EthioMarket Support</b>. They never impersonate the buyer or importer. <span className="text-ink-400">Ctrl + Enter to send.</span>
      </div>
    </div>
  );
}
