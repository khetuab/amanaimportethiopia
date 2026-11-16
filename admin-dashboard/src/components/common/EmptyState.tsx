import { Inbox } from 'lucide-react';
import { motion } from 'framer-motion';
import { StateArt } from '@/components/pro/Art';

export function EmptyState({ title, description, icon: Icon = Inbox, action }: {
  title: string; description?: string; icon?: React.ComponentType<{ className?: string }>; action?: React.ReactNode;
}) {
  return (
    <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }} className="py-12 text-center">
      <StateArt icon={Icon} />
      <h4 className="mt-2 text-lg font-semibold text-ink-900">{title}</h4>
      {description && <p className="text-sm text-ink-500 mt-1.5 max-w-sm mx-auto leading-relaxed">{description}</p>}
      {action && <div className="mt-5">{action}</div>}
    </motion.div>
  );
}
