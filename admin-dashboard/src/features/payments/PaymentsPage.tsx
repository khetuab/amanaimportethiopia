import { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  CheckCircle2, XCircle, ExternalLink, Copy, Check, Banknote, Smartphone, Landmark, Receipt, Hourglass,
  CreditCard, Eye, User, CalendarClock, ShieldCheck, Wallet,
} from 'lucide-react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';
import { Card } from '@/components/common/Card';
import { Badge } from '@/components/common/Badge';
import { Button } from '@/components/common/Button';
import { Textarea } from '@/components/common/Input';
import { Modal } from '@/components/common/Modal';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { SkeletonCards } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { FilterBar, SegmentedFilter } from '@/components/pro/FilterBar';
import { Timeline } from '@/components/pro/Timeline';
import { InfoList, InfoRow } from '@/components/pro/InfoList';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { usePaymentsList, useReviewPayment } from './usePayments';
import { ReceiptPreview } from '@/components/pro/ReceiptPreview';
import { fmtDateTime, fmtETB, humanize, relativeTime } from '@/lib/formatters';
import type { PaymentRecord } from '@/api/payments.api';

const statusTone = { submitted: 'amber', verified: 'emerald', rejected: 'red', reversed: 'slate', disputed: 'blue' } as const;
const FILTERS = [
  { value: 'submitted', label: 'Awaiting review' }, { value: 'verified', label: 'Verified' }, { value: 'rejected', label: 'Rejected' },
  { value: 'reversed', label: 'Reversed' }, { value: 'disputed', label: 'Disputed' }, { value: '', label: 'All' },
];

function channelIcon(ch: string) {
  const s = ch.toLowerCase();
  if (s.includes('bank')) return Landmark;
  if (s.includes('birr') || s.includes('tele') || s.includes('mobile')) return Smartphone;
  return Banknote;
}

function CopyButton({ text }: { text: string }) {
  const [done, setDone] = useState(false);
  return (
    <button type="button" aria-label="Copy reference" onClick={(e) => { e.stopPropagation(); navigator.clipboard?.writeText(text); setDone(true); setTimeout(() => setDone(false), 1400); }}
      className="p-1.5 rounded-lg text-ink-400 hover:text-emerald-700 hover:bg-emerald-50 transition-colors">
      {done ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
    </button>
  );
}

export default function PaymentsPage() {
  const [status, setStatus] = useState('submitted');
  const [viewing, setViewing] = useState<PaymentRecord | null>(null);
  const [confirm, setConfirm] = useState<{ action: 'verify' | 'reject'; record: PaymentRecord } | null>(null);
  const [note, setNote] = useState('');
  const q = usePaymentsList({ status: status || undefined, limit: 100 });
  const mut = useReviewPayment();
  const items = q.data?.items ?? [];
  const total = items.reduce((s, r) => s + (r.amountETB ?? 0), 0);

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Manual payment review" eyebrowIcon={ShieldCheck}
        title="Payments"
        subtitle={<>Evidence starts <b className="text-white">unverified</b>. Only your review advances the order — every decision is audited.</>}
        art="payments"
        stats={[
          { label: 'In this view', value: <CountUp value={items.length} />, icon: Receipt },
          { label: 'Total amount', value: <CountUp value={total} format={fmtETB} />, icon: Wallet },
          { label: 'Awaiting review', value: <CountUp value={items.filter((i) => i.status === 'submitted').length} />, icon: Hourglass },
        ]}
      />

      <FilterBar><SegmentedFilter options={FILTERS} value={status} onChange={setStatus} /></FilterBar>

      {q.isError ? (
        <Card><ErrorState message="Failed to load payments." onRetry={() => q.refetch()} /></Card>
      ) : q.isLoading ? (
        <SkeletonCards />
      ) : items.length === 0 ? (
        <Card><EmptyState title={status === 'submitted' ? 'Inbox zero — nothing to review' : 'No payments in this view'} description={status === 'submitted' ? 'New payment evidence from buyers will show up here.' : 'Try a different status filter.'} icon={CreditCard} /></Card>
      ) : (
        <Stagger className="grid gap-5 md:grid-cols-2 2xl:grid-cols-3" gap={0.06} key={status}>
          {items.map((r) => {
            const Chan = channelIcon(r.paymentChannel);
            const order = typeof r.order === 'object' ? r.order : null;
            const buyer = typeof r.buyer === 'object' ? r.buyer : null;
            return (
              <StaggerItem key={r._id}>
                <Card hover className="h-full overflow-hidden flex flex-col">
                  <div className={`h-1.5 ${r.status === 'submitted' ? 'bg-gradient-to-r from-amber-300 to-amber-500' : r.status === 'verified' ? 'bg-gradient-to-r from-emerald-400 to-emerald-600' : r.status === 'rejected' ? 'bg-gradient-to-r from-rose-400 to-red-600' : 'bg-ink-300'}`} />
                  <div className="p-5 flex-1">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="text-xs text-ink-500">Amount</div>
                        <div className="text-2xl font-semibold text-emerald-950 leading-tight">{fmtETB(r.amountETB)}</div>
                      </div>
                      <Badge tone={statusTone[r.status]} pulse={r.status === 'submitted'}>{humanize(r.status)}</Badge>
                    </div>

                    <div className="mt-4 space-y-2.5 text-sm">
                      <div className="flex items-center gap-2.5 text-ink-700">
                        <Receipt className="w-4 h-4 text-ink-400" />
                        {order ? <Link to={`/admin/orders/${order._id}`} className="font-medium text-emerald-800 hover:underline">{order.referenceNumber}</Link> : <span className="font-medium">{String(r.order)}</span>}
                      </div>
                      {buyer && <div className="flex items-center gap-2.5 text-ink-600"><User className="w-4 h-4 text-ink-400" />{buyer.fullName}</div>}
                      <div className="flex items-center gap-2.5 text-ink-600"><Chan className="w-4 h-4 text-ink-400" />{humanize(r.paymentChannel)}</div>
                      <div className="flex items-center gap-2.5 text-ink-600"><CalendarClock className="w-4 h-4 text-ink-400" />Paid {fmtDateTime(r.paidAt)} <span className="text-ink-400">· submitted {relativeTime(r.createdAt)}</span></div>
                    </div>

                    <div className="mt-4 flex items-center justify-between rounded-2xl bg-ink-50 border border-ink-100 pl-3.5 pr-1.5 py-1.5">
                      <div className="min-w-0"><div className="text-[10px] uppercase tracking-wider text-ink-400">Transaction ref</div><div className="font-mono text-xs text-ink-900 truncate">{r.transactionReference}</div></div>
                      <CopyButton text={r.transactionReference} />
                    </div>

                    {(r.receiptViewUrl ?? r.receiptUrl) ? (
                      <button type="button" onClick={() => setViewing(r)} className="mt-3 w-full flex items-center gap-3 rounded-2xl border border-emerald-200 bg-emerald-50/60 p-2 pr-3 text-left hover:bg-emerald-50 transition-colors">
                        {(r.receiptMimeType ?? '').includes('pdf')
                          ? <span className="w-12 h-12 rounded-xl bg-white flex items-center justify-center text-emerald-700"><Receipt className="w-5 h-5" /></span>
                          : <img src={(r.receiptViewUrl ?? r.receiptUrl)!} alt="" loading="lazy" referrerPolicy="no-referrer" className="w-12 h-12 rounded-xl object-cover bg-white" />}
                        <span className="text-sm font-medium text-emerald-900">Receipt attached<span className="block text-xs font-normal text-ink-500">Tap to view</span></span>
                      </button>
                    ) : (
                      <div className="mt-3 rounded-2xl bg-amber-50 text-amber-800 ring-1 ring-amber-200 px-3 py-2 text-xs">No receipt attached — check the bank statement.</div>
                    )}
                  </div>

                  <div className="px-5 pb-5 flex flex-wrap gap-2">
                    <Button variant="soft" size="sm" onClick={() => setViewing(r)}><Eye className="w-3.5 h-3.5" /> Evidence</Button>
                    {r.status === 'submitted' && (
                      <>
                        <Button size="sm" className="flex-1" onClick={() => setConfirm({ action: 'verify', record: r })}><CheckCircle2 className="w-3.5 h-3.5" /> Verify</Button>
                        <Button variant="danger" size="sm" className="flex-1" onClick={() => setConfirm({ action: 'reject', record: r })}><XCircle className="w-3.5 h-3.5" /> Reject</Button>
                      </>
                    )}
                  </div>
                </Card>
              </StaggerItem>
            );
          })}
        </Stagger>
      )}

      <Modal open={!!viewing} onClose={() => setViewing(null)} title="Payment evidence" subtitle={viewing ? fmtETB(viewing.amountETB) : undefined} icon={Receipt} width="max-w-xl">
        {viewing && (
          <div className="space-y-6">
            <InfoList>
              <InfoRow label="Transaction reference" value={viewing.transactionReference} mono />
              <InfoRow label="Amount" value={fmtETB(viewing.amountETB)} bold />
              <InfoRow label="Channel" value={humanize(viewing.paymentChannel)} />
              <InfoRow label="Paid at" value={fmtDateTime(viewing.paidAt)} />
              <InfoRow label="Submitted at" value={fmtDateTime(viewing.createdAt)} />
              {viewing.rejectionReason && <InfoRow label="Rejection reason" value={viewing.rejectionReason} />}
            </InfoList>
            {(viewing.receiptViewUrl ?? viewing.receiptUrl) ? (
              <div>
                <div className="text-sm font-semibold text-ink-900 mb-3">Receipt</div>
                <ReceiptPreview url={(viewing.receiptViewUrl ?? viewing.receiptUrl)!} mime={viewing.receiptMimeType} />
              </div>
            ) : (
              <div className="rounded-2xl bg-amber-50 text-amber-800 ring-1 ring-amber-200 px-4 py-3 text-sm">The buyer did not attach a receipt. Compare the reference with your bank statement before verifying.</div>
            )}
            <div>
              <div className="text-sm font-semibold text-ink-900 mb-3">Review history</div>
              {viewing.reviewHistory.length === 0 ? <div className="text-sm text-ink-500">No reviews yet.</div> : (
                <Timeline items={viewing.reviewHistory.map((h, i) => ({
                  key: String(i), title: humanize(h.action), meta: `${humanize(h.actorRole)} · ${fmtDateTime(h.at)}`, body: h.note,
                  tone: h.action === 'verify' ? 'emerald' : h.action === 'reject' ? 'red' : 'slate',
                }))} />
              )}
            </div>
          </div>
        )}
      </Modal>

      <ConfirmDialog
        open={!!confirm}
        onCancel={() => { setConfirm(null); setNote(''); }}
        onConfirm={async () => {
          if (!confirm) return;
          await mut.mutateAsync({ id: confirm.record._id, action: confirm.action, note, rejectionReason: confirm.action === 'reject' ? note : undefined });
          toast.success('Payment review saved');
          setConfirm(null); setNote('');
        }}
        title={confirm?.action === 'verify' ? 'Verify this payment?' : 'Reject this payment evidence?'}
        description={
          <div className="space-y-3">
            <p>{confirm?.action === 'verify' ? 'The order will move to payment_condition_satisfied. This is recorded in the audit log.' : 'The buyer will be able to resubmit. This is recorded in the audit log.'}</p>
            <Textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder={confirm?.action === 'reject' ? 'Reason for rejection…' : 'Note (optional)…'} className="min-h-[90px]" />
          </div>
        }
        confirmLabel={confirm?.action === 'verify' ? 'Verify payment' : 'Reject'}
        destructive={confirm?.action === 'reject'}
      />
    </div>
  );
}
