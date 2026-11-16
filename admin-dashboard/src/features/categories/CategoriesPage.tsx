import { useState } from 'react';
import { toast } from 'sonner';
import { Plus, Tags, Trash2, Lock, Eye, Layers, ShieldAlert, Smartphone, Cog, Shirt, Armchair, Package, Wrench, Laptop, Car } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { Card } from '@/components/common/Card';
import { Button } from '@/components/common/Button';
import { Badge } from '@/components/common/Badge';
import { Input, Textarea } from '@/components/common/Input';
import { Modal } from '@/components/common/Modal';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { EmptyState } from '@/components/common/EmptyState';
import { ErrorState } from '@/components/common/ErrorState';
import { SkeletonCards } from '@/components/common/Skeleton';
import { PageHero } from '@/components/pro/PageHero';
import { Switch } from '@/components/pro/Switch';
import { CountUp, Stagger, StaggerItem } from '@/components/pro/motion';
import { useCategoriesList, useCreateCategory, useDeleteCategory, useUpdateCategory } from './useCategories';
import type { Category } from '@/api/categories.api';

function iconFor(name: string): LucideIcon {
  const s = name.toLowerCase();
  if (/(phone|mobile|electronic)/.test(s)) return Smartphone;
  if (/(computer|laptop|tech)/.test(s)) return Laptop;
  if (/(machin|equip|industr)/.test(s)) return Cog;
  if (/(cloth|shoe|foot|fashion|apparel)/.test(s)) return Shirt;
  if (/(furnit|home|kitchen)/.test(s)) return Armchair;
  if (/(spare|part|tool)/.test(s)) return Wrench;
  if (/(auto|car|vehicle)/.test(s)) return Car;
  return Package;
}

export default function CategoriesPage() {
  const q = useCategoriesList();
  const create = useCreateCategory();
  const update = useUpdateCategory();
  const remove = useDeleteCategory();

  const [createOpen, setCreateOpen] = useState(false);
  const [form, setForm] = useState({ name: '', description: '' });
  const [toDelete, setToDelete] = useState<Category | null>(null);
  const rows = q.data ?? [];

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Catalog setup" eyebrowIcon={Layers}
        title="Categories"
        subtitle="Configurable product categories. Restricted categories are hidden from public importer discovery."
        art="categories"
        actions={<Button variant="gold" onClick={() => setCreateOpen(true)}><Plus className="w-4 h-4" /> New category</Button>}
        stats={[
          { label: 'Categories', value: <CountUp value={rows.length} />, icon: Tags },
          { label: 'Active', value: <CountUp value={rows.filter((c) => c.isActive).length} />, icon: Eye },
          { label: 'Restricted', value: <CountUp value={rows.filter((c) => c.isRestricted).length} />, icon: ShieldAlert },
        ]}
      />

      {q.isError ? (
        <Card><ErrorState message="Failed to load categories." onRetry={() => q.refetch()} /></Card>
      ) : q.isLoading ? <SkeletonCards /> : rows.length === 0 ? (
        <Card><EmptyState title="No categories" description="Create your first category to enable requests." icon={Tags} action={<Button onClick={() => setCreateOpen(true)}><Plus className="w-4 h-4" /> New category</Button>} /></Card>
      ) : (
        <Stagger className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3" gap={0.05}>
          {rows.map((c) => {
            const Icon = iconFor(c.name);
            return (
              <StaggerItem key={c._id}>
                <Card hover className={`h-full p-5 transition-opacity ${c.isActive ? '' : 'opacity-70'}`}>
                  <div className="flex items-start gap-4">
                    <div className={`w-14 h-14 shrink-0 rounded-2xl flex items-center justify-center transition-colors ${c.isActive ? 'bg-gradient-to-br from-emerald-400 to-emerald-700 text-white shadow-lg' : 'bg-ink-100 text-ink-400'}`}><Icon className="w-7 h-7" /></div>
                    <div className="min-w-0 flex-1">
                      <div className="font-semibold text-ink-900 truncate">{c.name}</div>
                      <div className="font-mono text-[11px] text-ink-400 truncate">/{c.slug}</div>
                      <div className="mt-2 flex gap-1.5 flex-wrap">
                        <Badge tone={c.isActive ? 'emerald' : 'slate'} dot>{c.isActive ? 'Active' : 'Disabled'}</Badge>
                        {c.isRestricted && <Badge tone="red"><Lock className="w-3 h-3" /> Restricted</Badge>}
                      </div>
                    </div>
                    <button onClick={() => setToDelete(c)} aria-label={`Delete ${c.name}`} className="p-2 rounded-xl text-ink-300 hover:text-red-600 hover:bg-red-50 transition-colors"><Trash2 className="w-4 h-4" /></button>
                  </div>
                  {c.description && <p className="mt-4 text-sm text-ink-500 line-clamp-2">{c.description}</p>}
                  <div className="mt-5 pt-4 border-t border-ink-100 space-y-3">
                    <div className="flex items-center justify-between text-sm"><span className="text-ink-700">Active</span><Switch label={`Toggle ${c.name} active`} checked={c.isActive} onChange={() => update.mutate({ id: c._id, patch: { isActive: !c.isActive } })} /></div>
                    <div className="flex items-center justify-between text-sm"><span className="text-ink-700">Restricted</span><Switch label={`Toggle ${c.name} restricted`} checked={c.isRestricted} onChange={() => update.mutate({ id: c._id, patch: { isRestricted: !c.isRestricted } })} /></div>
                  </div>
                </Card>
              </StaggerItem>
            );
          })}
        </Stagger>
      )}

      <Modal
        open={createOpen} onClose={() => setCreateOpen(false)} title="New category" subtitle="Appears in the buyer request form." icon={Tags}
        footer={
          <>
            <Button variant="ghost" onClick={() => setCreateOpen(false)}>Cancel</Button>
            <Button loading={create.isPending} onClick={async () => {
              if (!form.name.trim()) return;
              await create.mutateAsync({ name: form.name.trim(), description: form.description.trim() || undefined });
              toast.success('Category created'); setForm({ name: '', description: '' }); setCreateOpen(false);
            }}>Create</Button>
          </>
        }
      >
        <div className="space-y-4">
          <Input label="Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} icon={<Tags />} autoFocus />
          <Textarea label="Description (optional)" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} className="min-h-[80px]" />
        </div>
      </Modal>

      <ConfirmDialog
        open={!!toDelete}
        onCancel={() => setToDelete(null)}
        onConfirm={async () => {
          if (!toDelete) return;
          await remove.mutateAsync(toDelete._id);
          toast.success('Category deleted'); setToDelete(null);
        }}
        title="Delete category"
        description={`Delete "${toDelete?.name}"? Categories with subcategories cannot be deleted.`}
        confirmLabel="Delete"
        destructive
      />
    </div>
  );
}
