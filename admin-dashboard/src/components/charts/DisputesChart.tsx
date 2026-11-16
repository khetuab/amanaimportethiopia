import { ResponsiveContainer, PieChart, Pie, Cell, Tooltip } from 'recharts';
import { ChartTooltip } from './ChartTooltip';

export const CHART_COLORS = ['#047857', '#10b981', '#f59e0b', '#0ea5e9', '#8b5cf6', '#94a3b8', '#e11d48'];

export function DisputesChart({ data }: { data: { name: string; value: number }[] }) {
  const total = data.reduce((s, d) => s + d.value, 0);
  if (data.length === 0 || total === 0) return <div className="text-sm text-ink-500 py-16 text-center">No disputes yet.</div>;
  return (
    <div className="flex flex-col sm:flex-row items-center gap-6">
      <div className="relative w-[220px] h-[220px] shrink-0">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={data} dataKey="value" nameKey="name" innerRadius={72} outerRadius={104} paddingAngle={4} cornerRadius={8} stroke="none" animationDuration={1100}>
              {data.map((_, i) => <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />)}
            </Pie>
            <Tooltip content={<ChartTooltip />} />
          </PieChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          <div className="text-3xl font-semibold text-emerald-950">{total}</div>
          <div className="text-[11px] uppercase tracking-wider text-ink-500">Disputes</div>
        </div>
      </div>
      <ul className="flex-1 w-full space-y-2.5">
        {data.map((d, i) => (
          <li key={d.name} className="flex items-center gap-3 text-sm">
            <span className="w-2.5 h-2.5 rounded-full shrink-0" style={{ background: CHART_COLORS[i % CHART_COLORS.length] }} />
            <span className="flex-1 text-ink-600 truncate">{d.name}</span>
            <span className="font-semibold text-ink-900 tabular-nums">{d.value}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
