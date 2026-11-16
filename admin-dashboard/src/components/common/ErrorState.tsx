import { CloudOff, RefreshCw } from 'lucide-react';
import { motion } from 'framer-motion';
import { Button } from './Button';
import { StateArt } from '@/components/pro/Art';

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }} className="py-12 text-center">
      <StateArt icon={CloudOff} tone="red" />
      <h4 className="mt-2 text-lg font-semibold text-ink-900">Something went wrong</h4>
      <p className="text-sm text-ink-500 mt-1.5 max-w-sm mx-auto leading-relaxed">{message}</p>
      {onRetry && (
        <div className="mt-5">
          <Button variant="secondary" onClick={onRetry}><RefreshCw className="w-4 h-4" /> Try again</Button>
        </div>
      )}
    </motion.div>
  );
}
