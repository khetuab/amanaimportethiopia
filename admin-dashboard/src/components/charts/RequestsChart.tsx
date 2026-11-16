import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { ChartTooltip } from './ChartTooltip';

export function RequestsChart({ data }: { data: { name: string; value: number }[] }) {
  if (data.length === 0) return <div className="text-sm text-ink-500 py-16 text-center">No requests yet.</div>;
  return (
    <ResponsiveContainer width="100%" height={280}>
      <BarChart data={data} margin={{ top: 8, right: 4, left: -18, bottom: 0 }}>
        <defs>
          <linearGradient id="bar-req" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#34d399" /><stop offset="1" stopColor="#047857" />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 6" stroke="#e2e8f0" vertical={false} />
        <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} interval={0} height={48} angle={-18} textAnchor="end" />
        <YAxis tick={{ fontSize: 11, fill: '#64748b' }} allowDecimals={false} axisLine={false} tickLine={false} />
        <Tooltip cursor={{ fill: 'rgba(16,185,129,0.08)', radius: 8 }} content={<ChartTooltip />} />
        <Bar dataKey="value" fill="url(#bar-req)" radius={[10, 10, 4, 4]} maxBarSize={44} animationDuration={1000} />
      </BarChart>
    </ResponsiveContainer>
  );
}
