import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion';
import { useAuth } from '@/features/auth/useAuth';

export function ProtectedRoute() {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-emerald-950 text-white">
        <div className="relative">
          <span className="absolute inset-0 rounded-3xl bg-emerald-400/40 animate-ping-slow" />
          <motion.div animate={{ scale: [1, 1.06, 1] }} transition={{ duration: 1.8, repeat: Infinity }}
            className="relative w-16 h-16 rounded-3xl bg-gradient-to-br from-emerald-300 to-emerald-600 flex items-center justify-center text-emerald-950 font-display text-3xl shadow-[0_0_40px_rgba(52,211,153,0.5)]">
            ኢ
          </motion.div>
        </div>
        <p className="mt-6 text-sm text-emerald-200/80">Preparing your workspace…</p>
      </div>
    );
  }
  if (!user) return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  return <Outlet />;
}
