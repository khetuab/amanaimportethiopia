interface Payload { name?: string; value?: number | string; color?: string; payload?: { name?: string } }

export function ChartTooltip({
  active, payload, label, format,
}: { active?: boolean; payload?: Payload[]; label?: string; format?: (n: number) => string }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-2xl bg-emerald-950 text-white px-3.5 py-2.5 shadow-elev border border-white/10 text-xs">
      <div className="text-emerald-300/80 mb-1">{label ?? payload[0].payload?.name ?? payload[0].name}</div>
      {payload.map((p, i) => (
        <div key={i} className="flex items-center gap-2 font-semibold text-sm">
          <span className="w-2 h-2 rounded-full" style={{ background: p.color ?? '#34d399' }} />
          {typeof p.value === 'number' && format ? format(p.value) : p.value}
        </div>
      ))}
    </div>
  );
}
