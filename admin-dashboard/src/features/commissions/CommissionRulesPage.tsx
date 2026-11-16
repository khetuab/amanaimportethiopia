import { useState } from 'react';
import { toast } from 'sonner';
import { Plus, Percent, Banknote, User, Store, PowerOff, CalendarDays, Layers, GitBranch, CheckCircle2, ShieldCheck } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { Input } from '@/components/common/Input';
import { Select } from '@/components/common/Select';
import { Modal } from '@/components/common/Modal';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { SkeletonCards } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import {
  useCommissionRules, useCreateCommissionRule, useDeactivateCommissionRule,
} from './useCommissions';
import { fmtDate, fmtETB, humanize } from '@/lib/formatters';

export default function CommissionRulesPage() {
  const q = useCommissionRules();
  const deact = useDeactivateCommissionRule();
  const [open, setOpen] = useState(false);
  const rows = q.data ?? [];

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Fee configuration" eyebrowIcon={ShieldCheck}
        title="Commission rules"
        subtitle="Versioned and immutable once created. Deactivate a rule to retire it — history is never rewritten."
        art="rules"
        actions={<Button variant="gold" onClick={() => setOpen(true)}><Plus className="w-4 h-4" /> New rule</Button>}
        stats={[
          { label: 'Rules', value: <CountUp value={rows.length} />, icon: Layers },
          { label: 'Active', value: <CountUp value={rows.filter((r) => r.isActive).length} />, icon: CheckCircle2 },
          { label: 'Retired', value: <CountUp value={rows.filter((r) => !r.isActive).length} />, icon: PowerOff },
        ]}
      />

      {q.isError ? (
        <Card><ErrorState message="Failed to load rules." onRetry={() => q.refetch()} /></Card>
      ) : q.isLoading ? <SkeletonCards /> : rows.length === 0 ? (
        <Card><EmptyState title="No commission rules" description="Create a default rule to allow acceptance." icon={Percent} action={<Button onClick={() => setOpen(true)}><Plus className="w-4 h-4" /> New rule</Button>} /></Card>
      ) : (
        <Stagger className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3" gap={0.06}>
          {rows.map((r) => {
            const pct = r.feeType === 'percentage';
            return (
              <StaggerItem key={r._id}>
                <Card hover className={`h-full overflow-hidden ${r.isActive ? '' : 'opacity-75'}`}>
                  <div className={`relative px-6 pt-6 pb-5 ${r.isActive ? 'bg-gradient-to-br from-emerald-50 via-white to-white' : 'bg-ink-50'}`}>
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="font-semibold text-ink-900 truncate">{r.name}</div>
                        <div className="inline-flex items-center gap-1 font-mono text-[11px] text-ink-500 mt-0.5"><GitBranch className="w-3 h-3" />{r.version}</div>
                      </div>
                      <Badge tone={r.isActive ? 'emerald' : 'slate'} pulse={r.isActive}>{r.isActive ? 'Active' : 'Inactive'}</Badge>
                    </div>
                    <div className="mt-5 flex items-end gap-3">
                      <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${r.isActive ? 'bg-gradient-to-br from-gold-300 to-gold-500 text-ink-900 shadow-lg' : 'bg-ink-200 text-ink-500'}`}>
                        {pct ? <Percent className="w-6 h-6" /> : <Banknote className="w-6 h-6" />}
                      </div>
                      <div>
                        <div className="text-4xl font-semibold text-emerald-950 leading-none">{pct ? <><CountUp value={r.percentage ?? 0} format={(n) => n.toFixed(n % 1 ? 1 : 0)} /><span className="text-2xl">%</span></> : <CountUp value={r.fixedAmountETB ?? 0} format={fmtETB} />}</div>
                        <div className="text-xs text-ink-500 mt-1.5">{pct ? 'of order value' : 'flat fee per order'}</div>
                      </div>
                    </div>
                  </div>
                  <div className="px-6 py-5 space-y-3 text-sm border-t border-ink-100">
                    <div className="flex items-center justify-between"><span className="text-ink-500">Paid by</span><span className="inline-flex items-center gap-1.5 font-medium">{r.payer === 'buyer' ? <User className="w-4 h-4 text-ink-400" /> : <Store className="w-4 h-4 text-ink-400" />}{humanize(r.payer)}</span></div>
                    {(r.minFeeETB != null || r.maxFeeETB != null) && (
                      <div className="flex items-center justify-between"><span className="text-ink-500">Fee range</span><span className="font-medium">{r.minFeeETB != null ? fmtETB(r.minFeeETB) : '—'} → {r.maxFeeETB != null ? fmtETB(r.maxFeeETB) : '—'}</span></div>
                    )}
                    <div className="flex items-center justify-between"><span className="text-ink-500">Effective from</span><span className="inline-flex items-center gap-1.5 font-medium"><CalendarDays className="w-4 h-4 text-ink-400" />{fmtDate(r.effectiveFrom)}</span></div>
                    {r.isActive && (
                      <Button size="sm" variant="secondary" className="w-full mt-1" loading={deact.isPending && deact.variables === r._id} onClick={async () => { await deact.mutateAsync(r._id); toast.success('Rule deactivated'); }}>
                        <PowerOff className="w-3.5 h-3.5" /> Deactivate
                      </Button>
                    )}
                  </div>
                </Card>
              </StaggerItem>
            );
          })}
        </Stagger>
      )}
      <CreateRuleModal open={open} onClose={() => setOpen(false)} />
    </div>
  );
}

function CreateRuleModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const create = useCreateCommissionRule();
  const [form, setForm] = useState({
    name: '', version: '',
    feeType: 'percentage' as 'percentage' | 'fixed',
    percentage: '5', fixedAmountETB: '', minFeeETB: '', maxFeeETB: '',
    payer: 'buyer' as 'buyer' | 'importer',
    effectiveFrom: new Date().toISOString().slice(0, 10),
  });

  return (
    <Modal
      open={open} onClose={onClose} title="New commission rule" subtitle="Rules are immutable once created." icon={Percent} width="max-w-xl"
      footer={
        <>
          <Button variant="ghost" onClick={onClose}>Cancel</Button>
          <Button loading={create.isPending} onClick={async () => {
            await create.mutateAsync({
              name: form.name,
              version: form.version,
              feeType: form.feeType,
              percentage: form.feeType === 'percentage' ? Number(form.percentage) : null,
              fixedAmountETB: form.feeType === 'fixed' ? Number(form.fixedAmountETB) : null,
              minFeeETB: form.minFeeETB ? Number(form.minFeeETB) : null,
              maxFeeETB: form.maxFeeETB ? Number(form.maxFeeETB) : null,
              payer: form.payer,
              effectiveFrom: new Date(form.effectiveFrom).toISOString(),
              effectiveUntil: null,
              isActive: true,
              categoryIds: [],
            });
            toast.success('Rule created');
            onClose();
          }}>Create</Button>
        </>
      }
    >
      <div className="grid gap-4">
        <Input label="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
        <Input label="Version" placeholder="2026-01-01.v1" value={form.version} onChange={(e) => setForm({ ...form, version: e.target.value })} icon={<GitBranch />} />
        <div className="grid grid-cols-2 gap-3">
          <Select label="Fee type" value={form.feeType} onChange={(e) => setForm({ ...form, feeType: e.target.value as 'percentage' | 'fixed' })}>
            <option value="percentage">Percentage</option>
            <option value="fixed">Fixed ETB</option>
          </Select>
          <Select label="Payer" value={form.payer} onChange={(e) => setForm({ ...form, payer: e.target.value as 'buyer' | 'importer' })}>
            <option value="buyer">Buyer</option>
            <option value="importer">Importer</option>
          </Select>
        </div>
        {form.feeType === 'percentage'
          ? <Input label="Percentage" type="number" value={form.percentage} onChange={(e) => setForm({ ...form, percentage: e.target.value })} icon={<Percent />} />
          : <Input label="Fixed amount (ETB)" type="number" value={form.fixedAmountETB} onChange={(e) => setForm({ ...form, fixedAmountETB: e.target.value })} icon={<Banknote />} />}
        <div className="grid grid-cols-2 gap-3">
          <Input label="Min fee ETB" type="number" value={form.minFeeETB} onChange={(e) => setForm({ ...form, minFeeETB: e.target.value })} />
          <Input label="Max fee ETB" type="number" value={form.maxFeeETB} onChange={(e) => setForm({ ...form, maxFeeETB: e.target.value })} />
        </div>
        <Input label="Effective from" type="date" value={form.effectiveFrom} onChange={(e) => setForm({ ...form, effectiveFrom: e.target.value })} />
      </div>
    </Modal>
  );
}
