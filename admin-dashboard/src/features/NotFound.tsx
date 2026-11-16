import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Compass, ArrowLeft, LayoutDashboard } from 'lucide-react';
import { Button } from '@/components/common/Button';

export default function NotFound() {
  return (
    <div className="relative overflow-hidden rounded-[28px] bg-emerald-950 text-emerald-50 min-h-[70vh] flex flex-col items-center justify-center text-center p-8">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute -top-32 -left-24 w-[26rem] h-[26rem] rounded-full bg-emerald-600/40 blur-3xl animate-aurora" />
        <div className="absolute -bottom-40 right-0 w-[30rem] h-[30rem] rounded-full bg-teal-500/25 blur-3xl animate-aurora-rev" />
        <div className="absolute inset-0 bg-grid-light opacity-60 mask-fade-b" />
      </div>
      <div className="relative">
        <div className="relative inline-block">
          <motion.div animate={{ rotate: [0, 8, -6, 0] }} transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
            className="absolute -top-8 -right-8 w-16 h-16 rounded-2xl bg-white/10 border border-white/20 backdrop-blur flex items-center justify-center text-emerald-200"><Compass className="w-8 h-8" /></motion.div>
          <div className="font-display text-[8rem] sm:text-[11rem] leading-none bg-gradient-to-b from-white to-emerald-400/40 bg-clip-text text-transparent">404</div>
        </div>
        <motion.p initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }} className="mt-2 text-xl text-emerald-100">This shipment never arrived.</motion.p>
        <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.35 }} className="mt-2 text-emerald-200/70 max-w-sm mx-auto">The page you're looking for was moved, removed, or never existed.</motion.p>
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }} className="mt-8 flex flex-wrap justify-center gap-3">
          <Link to="/admin"><Button variant="gold"><LayoutDashboard className="w-4 h-4" /> Back to dashboard</Button></Link>
          <Button variant="glass" onClick={() => history.back()}><ArrowLeft className="w-4 h-4" /> Go back</Button>
        </motion.div>
      </div>
    </div>
  );
}
