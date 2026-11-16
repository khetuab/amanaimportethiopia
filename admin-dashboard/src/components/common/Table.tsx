import { ReactNode } from 'react';
import { motion } from 'framer-motion';
import { Skeleton } from './Skeleton';

interface Column<T> {
  key: string;
  header: ReactNode;
  render: (row: T) => ReactNode;
  className?: string;
}
interface Props<T> {
  columns: Column<T>[];
  rows: T[];
  keyFn: (row: T) => string;
  loading?: boolean;
  empty?: ReactNode;
  onRowClick?: (row: T) => void;
}

export function Table<T>({ columns, rows, keyFn, loading, empty, onRowClick }: Props<T>) {
  if (loading) {
    return (
      <div className="p-6 space-y-3">
        {[0, 1, 2, 3, 4].map((i) => <Skeleton key={i} className="h-12" />)}
      </div>
    );
  }
  if (rows.length === 0) return <div className="p-10 text-center text-ink-500">{empty ?? 'No records.'}</div>;
  return (
    <div className="overflow-x-auto scrollbar-thin">
      <table className="min-w-full text-sm">
        <thead>
          <tr className="bg-ink-50/80 border-b border-ink-200">
            {columns.map((c) => (
              <th key={c.key} className={`text-left text-[11px] font-semibold uppercase tracking-wider text-ink-500 px-5 py-3.5 whitespace-nowrap ${c.className ?? ''}`}>{c.header}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <motion.tr
              key={keyFn(row)}
              initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.35, delay: Math.min(i, 12) * 0.03 }}
              onClick={onRowClick ? () => onRowClick(row) : undefined}
              className={`group relative border-b border-ink-100 last:border-0 transition-colors ${onRowClick ? 'cursor-pointer hover:bg-emerald-50/50' : 'hover:bg-ink-50/50'}`}
            >
              {columns.map((c, ci) => (
                <td key={c.key} className={`relative px-5 py-4 text-ink-800 whitespace-nowrap ${c.className ?? ''}`}>
                  {ci === 0 && onRowClick && <span className="absolute left-0 top-2 bottom-2 w-1 rounded-r-full bg-emerald-500 scale-y-0 group-hover:scale-y-100 transition-transform origin-center" />}
                  {c.render(row)}
                </td>
              ))}
            </motion.tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
