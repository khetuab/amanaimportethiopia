import { Mail, Phone, ShieldCheck, CalendarDays, BadgeCheck, Languages, KeyRound, MailCheck, PhoneCall, UserCog } from 'lucide-react';
import { Card, CardBody, CardHeader } from '@/components/common/Card';
import { Badge } from '@/components/common/Badge';
import { Skeleton } from '@/components/common/Skeleton';
import { ErrorState } from '@/components/common/ErrorState';
import { PageHero } from '@/components/pro/PageHero';
import { InfoList, InfoRow } from '@/components/pro/InfoList';
import { Avatar } from '@/components/pro/Avatar';
import { Stagger, StaggerItem } from '@/components/pro/motion';
import { useMe } from './useUsers';
import { fmtDateTime, humanize } from '@/lib/formatters';

/**
 * Read-only current-admin view. Full user management is not required for the
 * initial pilot; when it becomes necessary, add a `/admin/users` backend
 * endpoint and mirror the pattern used by ImportersPage.
 */
export default function UsersPage() {
  const q = useMe();
  if (q.isLoading) return <div className="space-y-5"><Skeleton className="h-64 rounded-[28px]" /><Skeleton className="h-64 rounded-3xl" /></div>;
  if (q.isError || !q.data) return <ErrorState message="Failed to load profile." onRetry={() => q.refetch()} />;
  const u = q.data;

  return (
    <div className="space-y-6">
      <PageHero
        eyebrow="Your account" eyebrowIcon={UserCog}
        title={u.fullName}
        subtitle="Current administrator profile. Full user management lands post-pilot."
        art="users"
        meta={(
          <>
            <Badge tone="emerald" pulse>{humanize(u.status)}</Badge>
            <span className="inline-flex items-center gap-1.5"><ShieldCheck className="w-3.5 h-3.5" />{humanize(u.role)}</span>
            <span className="inline-flex items-center gap-1.5"><Mail className="w-3.5 h-3.5" />{u.email}</span>
          </>
        )}
      />

      <Stagger className="grid lg:grid-cols-3 gap-5" gap={0.08}>
        <StaggerItem className="lg:col-span-2">
          <Card className="h-full">
            <CardHeader icon={UserCog} title="Current administrator" />
            <CardBody>
              <div className="flex items-center gap-4 mb-4">
                <Avatar name={u.fullName} size={64} />
                <div><div className="text-lg font-semibold text-ink-900">{u.fullName}</div><div className="text-sm text-ink-500">{u.email}</div></div>
              </div>
              <InfoList>
                <InfoRow icon={Mail} label="Email" value={u.email} />
                <InfoRow icon={Phone} label="Phone" value={u.phone} />
                <InfoRow icon={ShieldCheck} label="Role" value={humanize(u.role)} />
                <InfoRow icon={BadgeCheck} label="Status" value={humanize(u.status)} />
                <InfoRow icon={Languages} label="Language" value={u.preferredLanguage?.toUpperCase() ?? '—'} />
                <InfoRow icon={CalendarDays} label="Joined" value={fmtDateTime(u.createdAt)} />
              </InfoList>
            </CardBody>
          </Card>
        </StaggerItem>
        <StaggerItem>
          <Card className="h-full">
            <CardHeader icon={KeyRound} title="Verification" />
            <CardBody className="space-y-3">
              {[
                { ok: u.isEmailVerified, label: 'Email verified', icon: MailCheck },
                { ok: u.isPhoneVerified, label: 'Phone verified', icon: PhoneCall },
              ].map((v) => (
                <div key={v.label} className={`flex items-center gap-3 rounded-2xl px-4 py-3.5 ring-1 ${v.ok ? 'bg-emerald-50 ring-emerald-200 text-emerald-900' : 'bg-ink-50 ring-ink-200 text-ink-600'}`}>
                  <v.icon className="w-5 h-5" /><span className="flex-1 text-sm font-medium">{v.label}</span><Badge tone={v.ok ? 'emerald' : 'slate'}>{v.ok ? 'Yes' : 'No'}</Badge>
                </div>
              ))}
              <p className="text-xs text-ink-500 leading-relaxed pt-2">Every action you take in this console is attributed to this account in the audit log.</p>
            </CardBody>
          </Card>
        </StaggerItem>
      </Stagger>
    </div>
  );
}
