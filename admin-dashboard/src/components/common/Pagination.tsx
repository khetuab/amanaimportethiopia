import { Button } from './Button';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export function Pagination({ page, totalPages, onPage }: { page: number; totalPages: number; onPage: (p: number) => void }) {
  if (totalPages <= 1) return null;
  const pct = (page / totalPages) * 100;
  return (
    <div className="flex items-center justify-between gap-4 px-6 py-3.5 border-t border-ink-100 bg-ink-50/50">
      <div className="flex items-center gap-3 min-w-0">
        <span className="text-sm text-ink-600 whitespace-nowrap">Page <b className="text-ink-900">{page}</b> of {totalPages}</span>
        <div className="hidden sm:block w-24 h-1.5 rounded-full bg-ink-200 overflow-hidden">
          <div className="h-full rounded-full bg-emerald-500 transition-all duration-500" style={{ width: `${pct}%` }} />
        </div>
      </div>
      <div className="flex gap-2">
        <Button variant="secondary" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          <ChevronLeft className="w-4 h-4" /> Prev
        </Button>
        <Button variant="secondary" size="sm" disabled={page >= totalPages} onClick={() => onPage(page + 1)}>
          Next <ChevronRight className="w-4 h-4" />
        </Button>
      </div>
    </div>
  );
}
