import { ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { ChartTooltip } from './ChartTooltip';
import { fmtETB } from '@/lib/formatters';

export function RevenueChart({ data }: { data: { name: string; value: number }[] }) {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <BarChart data={data} margin={{ top: 8, right: 4, left: -10, bottom: 0 }}>
        <defs>
          <linearGradient id="bar-rev" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="#fcd34d" /><stop offset="1" stopColor="#d97706" />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 6" stroke="#e2e8f0" vertical={false} />
        <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} />
        <YAxis tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} />
        <Tooltip cursor={{ fill: 'rgba(245,158,11,0.08)', radius: 8 }} content={<ChartTooltip format={fmtETB} />} />
        <Bar dataKey="value" fill="url(#bar-rev)" radius={[10, 10, 4, 4]} maxBarSize={44} animationDuration={1000} />
      </BarChart>
    </ResponsiveContainer>
  );
}
