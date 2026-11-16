const palettes = [
  'from-emerald-400 to-emerald-700', 'from-teal-400 to-teal-700', 'from-sky-400 to-sky-700',
  'from-amber-400 to-amber-600', 'from-violet-400 to-violet-700', 'from-rose-400 to-rose-600',
];

export function Avatar({ name, size = 40, className = '' }: { name?: string | null; size?: number; className?: string }) {
  const label = (name ?? '?').trim();
  const initials = label.split(/\s+/).slice(0, 2).map((p) => p.charAt(0).toUpperCase()).join('') || '?';
  const hue = [...label].reduce((a, c) => a + c.charCodeAt(0), 0) % palettes.length;
  return (
    <div
      className={`shrink-0 rounded-full bg-gradient-to-br ${palettes[hue]} text-white font-semibold flex items-center justify-center shadow-sm ring-2 ring-white ${className}`}
      style={{ width: size, height: size, fontSize: size * 0.38 }}
      aria-hidden
    >
      {initials}
    </div>
  );
}
