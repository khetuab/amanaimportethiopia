import { useState } from 'react';
import { motion } from 'framer-motion';
import { Modal } from './Modal';
import { Button } from './Button';
import { AlertTriangle, ShieldCheck } from 'lucide-react';

export function ConfirmDialog({
  open, onCancel, onConfirm, title, description, confirmLabel = 'Confirm', destructive,
}: {
  open: boolean; onCancel: () => void; onConfirm: () => void | Promise<void>;
  title: string; description: React.ReactNode; confirmLabel?: string; destructive?: boolean;
}) {
  const [loading, setLoading] = useState(false);
  const handle = async () => {
    setLoading(true);
    try { await onConfirm(); } finally { setLoading(false); }
  };
  const Icon = destructive ? AlertTriangle : ShieldCheck;
  return (
    <Modal
      open={open}
      onClose={onCancel}
      title={title}
      footer={
        <>
          <Button variant="ghost" onClick={onCancel}>Cancel</Button>
          <Button variant={destructive ? 'danger' : 'primary'} loading={loading} onClick={handle}>{confirmLabel}</Button>
        </>
      }
    >
      <div className="flex gap-4">
        <div className="relative shrink-0">
          <span className={`absolute inset-0 rounded-2xl animate-ping-slow ${destructive ? 'bg-red-300/60' : 'bg-emerald-300/60'}`} />
          <motion.div initial={{ scale: 0.5, rotate: -20 }} animate={{ scale: 1, rotate: 0 }} transition={{ type: 'spring', stiffness: 300, damping: 14 }}
            className={`relative w-12 h-12 rounded-2xl flex items-center justify-center ${destructive ? 'bg-red-50 text-red-600' : 'bg-emerald-50 text-emerald-700'}`}>
            <Icon className="w-6 h-6" />
          </motion.div>
        </div>
        <div className="text-ink-700 text-sm leading-relaxed min-w-0 flex-1 pt-1">{description}</div>
      </div>
    </Modal>
  );
}
