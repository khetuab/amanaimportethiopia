import { useState } from 'react';
import { useParams } from 'react-router-dom';
import {
  CheckCircle2, XCircle, PauseCircle, RotateCcw, FileText, ExternalLink, Image as ImageIcon, Star, Package,
  CalendarCheck, Mail, Phone, Building2, Hash, MapPin, ScrollText, Send, Eye, Gavel, ShieldCheck,
} from 'lucide-react';
import { toast } from 'sonner';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Badge } from '@/components/common/Badge';
import { Button } from '@/components/common/Button';
import { Textarea } from '@/components/common/Input';
import { Skeleton } from '@/components/common/Skeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { PageHero } from '@/components/pro/PageHero';
import { InfoList, InfoRow } from '@/components/pro/InfoList';
import { Stepper } from '@/components/pro/Stepper';
import { ProgressRing } from '@/components/pro/ProgressRing';
import { Stagger, StaggerItem, CountUp } from '@/components/pro/motion';
import { useImporter, useReviewImporter } from './useImporters';
import { fmtDate, fmtDateTime, humanize } from '@/lib/formatters';
import type { VerificationStatus } from '@/types/importer.types';

type Action = 'approve' | 'reject' | 'suspend' | 'reinstate' | 'expire';
const statusTone: Record<VerificationStatus, 'emerald' | 'amber' | 'red' | 'slate' | 'blue'> = {
  approved: 'emerald', pending: 'amber', rejected: 'red', suspended: 'slate', expired: 'blue',
};

export default function ImporterDetailPage() {
  const { id = '' } = useParams();
  const q = useImporter(id);
  const mut = useReviewImporter(id);
  const [confirm, setConfirm] = useState<{ action: Action; label: string; destructive?: boolean } | null>(null);
  const [notes, setNotes] = useState('');

  if (q.isLoading) return <div className="space-y-5"><Skeleton className="h-64 rounded-[28px]" /><Skeleton className="h-48 rounded-3xl" /><Skeleton className="h-64 rounded-3xl" /></div>;
  if (q.isError || !q.data) return <ErrorState message="Failed to load importer." onRetry={() => q.refetch()} />;

  const { profile, documents } = q.data;
  const status = profile.verificationStatus;
  const decisionLabel = status === 'approved' ? 'Approved' : status === 'rejected' ? 'Rejected' : status === 'suspended' ? 'Suspended' : status === 'expired' ? 'Expired' : 'Decision';
  const steps = [
    { key: 'submitted', label: 'Submitted', icon: Send },
    { key: 'review', label: 'Under review', icon: Eye },
    { key: 'decision', label: decisionLabel, icon: status === 'approved' ? ShieldCheck : Gavel },
  ];
  const current = status === 'pending' ? 1 : 2;
  const failed = status === 'rejected' || status === 'suspended' || status === 'expired';
  const rating = profile.ratingAverage ?? 0;

  return (
    <div className="space-y-6">
      <PageHero
        back={{ to: '/admin/importers', label: 'All importers' }}
        eyebrow="Importer profile" eyebrowIcon={Building2}
        title={profile.businessName}
        meta={(
          <>
            <Badge tone={statusTone[status]} pulse={status === 'pending'}>{humanize(status)}</Badge>
            <span className="inline-flex items-center gap-1.5"><Mail className="w-3.5 h-3.5" />{profile.user?.email}</span>
            <span className="inline-flex items-center gap-1.5"><Phone className="w-3.5 h-3.5" />{profile.user?.phone}</span>
          </>
        )}
        subtitle={profile.user?.fullName ? `Account owner: ${profile.user.fullName}` : undefined}
        art="importers"
        actions={(
          <>
            {status === 'pending' && (
              <>
                <Button variant="gold" onClick={() => setConfirm({ action: 'approve', label: 'Approve importer' })}><CheckCircle2 className="w-4 h-4" /> Approve</Button>
                <Button variant="danger" onClick={() => setConfirm({ action: 'reject', label: 'Reject importer', destructive: true })}><XCircle className="w-4 h-4" /> Reject</Button>
              </>
            )}
            {status === 'approved' && <Button variant="danger" onClick={() => setConfirm({ action: 'suspend', label: 'Suspend importer', destructive: true })}><PauseCircle className="w-4 h-4" /> Suspend</Button>}
            {status === 'suspended' && <Button variant="gold" onClick={() => setConfirm({ action: 'reinstate', label: 'Reinstate importer' })}><RotateCcw className="w-4 h-4" /> Reinstate</Button>}
          </>
        )}
      />

      <Card>
        <CardBody className="py-7"><Stepper steps={steps} current={current} failed={failed} completed={status === 'approved'} /></CardBody>
      </Card>

      <Stagger className="grid lg:grid-cols-3 gap-5" gap={0.08}>
        <StaggerItem className="lg:col-span-2">
          <Card className="h-full">
            <CardHeader icon={Building2} title="Business profile" />
            <CardBody>
              <InfoList>
                <InfoRow icon={Building2} label="Type" value={humanize(profile.businessType)} />
                <InfoRow icon={Hash} label="TIN" value={profile.tinNumber ?? '—'} mono />
                <InfoRow icon={ScrollText} label="License #" value={profile.businessLicenseNumber ?? '—'} mono />
                <InfoRow icon={MapPin} label="Service areas" value={(profile.serviceAreas ?? []).length ? (
                  <span className="flex flex-wrap gap-1.5 justify-end">{(profile.serviceAreas ?? []).map((a) => <span key={a} className="px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 text-xs ring-1 ring-emerald-200">{a}</span>)}</span>
                ) : '—'} />
                <InfoRow label="Description" value={profile.description || '—'} />
                <InfoRow icon={CalendarCheck} label="Submitted" value={fmtDateTime(profile.createdAt)} />
                {profile.verificationNotes && <InfoRow label="Admin notes" value={profile.verificationNotes} />}
              </InfoList>
            </CardBody>
          </Card>
        </StaggerItem>
        <StaggerItem>
          <Card className="h-full">
            <CardHeader icon={Star} title="Reputation" />
            <CardBody className="flex flex-col items-center">
              <ProgressRing value={(rating / 5) * 100} size={150} label={<span className="inline-flex items-center gap-1">{rating.toFixed(1)}<Star className="w-5 h-5 fill-gold-400 text-gold-400" /></span>} sub={`${profile.ratingCount ?? 0} reviews`} />
              <div className="grid grid-cols-2 gap-3 w-full mt-6">
                <div className="rounded-2xl bg-emerald-50 p-3 text-center"><div className="flex justify-center items-center gap-1.5 text-xl font-semibold text-emerald-900"><Package className="w-4 h-4" /><CountUp value={profile.completedOrdersCount ?? 0} /></div><div className="text-[11px] text-emerald-800/70">Completed orders</div></div>
                <div className="rounded-2xl bg-ink-50 p-3 text-center"><div className="text-sm font-semibold text-ink-900 mt-1.5">{profile.verifiedAt ? fmtDate(profile.verifiedAt) : '—'}</div><div className="text-[11px] text-ink-500 mt-1">Verified on</div></div>
              </div>
            </CardBody>
          </Card>
        </StaggerItem>
      </Stagger>

      <Card>
        <CardHeader icon={FileText} title="Verification documents" subtitle={`${documents.length} uploaded`} />
        <CardBody>
          {documents.length === 0 ? (
            <div className="text-sm text-ink-500 py-6 text-center">No documents uploaded.</div>
          ) : (
            <Stagger className="grid md:grid-cols-2 xl:grid-cols-3 gap-4" gap={0.06}>
              {documents.map((d) => {
                const Icon = d.mimeType?.startsWith('image/') ? ImageIcon : FileText;
                return (
                  <StaggerItem key={d._id}>
                    <a href={d.fileUrl} target="_blank" rel="noreferrer" className="group flex items-center gap-4 rounded-2xl border border-ink-200 p-4 bg-white hover:border-emerald-300 hover:shadow-card hover:-translate-y-0.5 transition-all">
                      <div className="w-12 h-12 shrink-0 rounded-2xl bg-gradient-to-br from-emerald-50 to-emerald-100 text-emerald-700 flex items-center justify-center group-hover:from-emerald-500 group-hover:to-emerald-700 group-hover:text-white transition-all"><Icon className="w-6 h-6" /></div>
                      <div className="min-w-0 flex-1">
                        <div className="text-sm font-semibold truncate">{humanize(d.type)}</div>
                        <div className="text-xs text-ink-500">{d.mimeType} · {(d.size / 1024).toFixed(0)} KB</div>
                      </div>
                      <ExternalLink className="w-4 h-4 text-ink-300 group-hover:text-emerald-600 transition-colors" />
                    </a>
                  </StaggerItem>
                );
              })}
            </Stagger>
          )}
        </CardBody>
      </Card>

      <ConfirmDialog
        open={!!confirm}
        onCancel={() => { setConfirm(null); setNotes(''); }}
        onConfirm={async () => {
          if (!confirm) return;
          await mut.mutateAsync({ action: confirm.action, notes });
          toast.success('Importer updated');
          setConfirm(null); setNotes('');
        }}
        title={confirm?.label ?? ''}
        description={
          <div className="space-y-3">
            <p>This action will be recorded in the audit log.</p>
            <Textarea value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Add a note (optional)…" className="min-h-[90px]" />
          </div>
        }
        confirmLabel={confirm?.action === 'approve' ? 'Approve' : 'Confirm'}
        destructive={confirm?.destructive}
      />
    </div>
  );
}
