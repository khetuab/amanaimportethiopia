import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Card } from '@/components/common/Card';
import { Badge } from '@/components/common/Badge';
import { Button } from '@/components/common/Button';
import { Skeleton } from '@/components/common/Skeleton';
import { listLegalChecklist, updateLegalChecklist } from '@/api/admin.api';
import { fmtDate, humanize } from '@/lib/formatters';
import type { LegalChecklistItem } from '@/types/admin.types';

const tone = {
  not_started: 'slate', in_review: 'amber', advice_obtained: 'blue', enabled: 'emerald',
} as const;

export default function LegalPage() {
  const qc = useQueryClient();
  const q = useQuery({ queryKey: ['legal'], queryFn: listLegalChecklist });
  const mut = useMutation({
    mutationFn: ({ item, status }: { item: string; status: LegalChecklistItem['status'] }) =>
      updateLegalChecklist(item, { status }),
    onSuccess: () => {
      toast.success('Checklist updated');
      qc.invalidateQueries({ queryKey: ['legal'] });
    },
  });

  if (q.isLoading) return <Skeleton className="h-64" />;
  const items = q.data ?? [];
  const groups = items.reduce<Record<string, LegalChecklistItem[]>>((acc, it) => {
    (acc[it.category] ||= []).push(it);
    return acc;
  }, {});

  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-3xl text-emerald-950">Legal review checklist</h1>
        <p className="text-ink-500 mt-1">
          Tracking only. <b>This is not a compliance claim.</b> Manual payments must remain
          disabled until the corresponding items reach <i>enabled</i> with professional advice on file.
        </p>
      </div>

      {Object.entries(groups).map(([cat, list]) => (
        <Card key={cat}>
          <div className="p-5 border-b border-ink-100">
            <h3 className="font-semibold text-emerald-950">{humanize(cat)}</h3>
          </div>
          <div className="divide-y divide-ink-100">
            {list.map((it) => (
              <div key={it._id} className="p-4 flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <div className="text-sm font-medium text-ink-900">{it.label}</div>
                  <div className="text-xs text-ink-500 mt-0.5">
                    {it.gatesCapability && <>Gates: <code className="font-mono">{it.gatesCapability}</code> · </>}
                    {it.reviewedAt && <>Last reviewed {fmtDate(it.reviewedAt)}</>}
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Badge tone={tone[it.status]}>{humanize(it.status)}</Badge>
                  <select
                    value={it.status}
                    onChange={(e) => mut.mutate({ item: it.item, status: e.target.value as LegalChecklistItem['status'] })}
                    className="h-9 rounded-lg border border-ink-200 px-2 bg-white text-sm"
                  >
                    <option value="not_started">Not started</option>
                    <option value="in_review">In review</option>
                    <option value="advice_obtained">Advice obtained</option>
                    <option value="enabled">Enabled</option>
                  </select>
                </div>
              </div>
            ))}
          </div>
        </Card>
      ))}

      {items.length === 0 && (
        <Card>
          <div className="p-8 text-center text-ink-500">
            No checklist items seeded. Run <code className="font-mono">npm run seed:legal</code> in the backend.
          </div>
        </Card>
      )}

      <div className="text-xs text-ink-500 max-w-2xl">
        Reminder: <b>Phase 1.8’s legal checklist is a tracking tool</b>, not legal approval.
        Do not enable manual payments until the corresponding items have professional sign-off.
      </div>
    </div>
  );
}