import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card } from '@/components/common/Card';
import { Table } from '@/components/common/Table';
import { Input } from '@/components/common/Input';
import { EmptyState } from '@/components/common/EmptyState';
import { listAudit } from '@/api/admin.api';
import { fmtDateTime, humanize } from '@/lib/formatters';
import type { AuditLogEntry } from '@/types/admin.types';

export default function AuditPage() {
  const [action, setAction] = useState('');
  const q = useQuery({
    queryKey: ['audit', action],
    queryFn: () => listAudit({ action: action || undefined, limit: 50 }),
  });
  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-3xl text-emerald-950">Audit log</h1>
        <p className="text-ink-500 mt-1">Every privileged action is recorded.</p>
      </div>
      <Card>
        <div className="p-4 w-72">
          <Input label="Action filter" value={action} onChange={(e) => setAction(e.target.value)} placeholder="e.g. importer.approve" />
        </div>
        <Table<AuditLogEntry>
          keyFn={(r) => r._id}
          loading={q.isLoading}
          rows={q.data?.items ?? []}
          empty={<EmptyState title="No audit entries" />}
          columns={[
            {
              key: 'actor', header: 'Actor',
              render: (r) => typeof r.actor === 'object' ? r.actor.fullName : '—',
            },
            { key: 'action', header: 'Action', render: (r) => <span className="font-mono text-xs">{r.action}</span> },
            { key: 'target', header: 'Target', render: (r) => `${r.targetType}:${r.targetId.slice(-6)}` },
            { key: 'created', header: 'At', render: (r) => fmtDateTime(r.createdAt) },
          ]}
        />
      </Card>
    </div>
  );
}