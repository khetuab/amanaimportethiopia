import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ExternalLink, FileText, ImageOff, Maximize2, X } from 'lucide-react';

/** Inline receipt viewer: image preview + full-screen zoom. PDFs fall back to a link. */
export function ReceiptPreview({ url, mime }: { url: string; mime?: string | null }) {
  const [zoom, setZoom] = useState(false);
  const [failed, setFailed] = useState(false);
  const isPdf = (mime ?? '').includes('pdf') || /\.pdf($|\?)/i.test(url);

  if (isPdf || failed) {
    return (
      <a href={url} target="_blank" rel="noreferrer"
        className="group flex items-center justify-between rounded-2xl border border-emerald-200 bg-emerald-50/60 px-4 py-3 text-emerald-800 hover:bg-emerald-50 transition-colors">
        <span className="inline-flex items-center gap-2 font-medium text-sm">
          {failed ? <ImageOff className="w-4 h-4" /> : <FileText className="w-4 h-4" />}
          {failed ? 'Preview unavailable — open receipt' : 'Open receipt (PDF)'}
        </span>
        <ExternalLink className="w-4 h-4 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
      </a>
    );
  }

  return (
    <>
      <button type="button" onClick={() => setZoom(true)}
        className="group relative block w-full overflow-hidden rounded-2xl border border-ink-200 bg-ink-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500">
        <img src={url} alt="Payment receipt" loading="lazy" referrerPolicy="no-referrer" onError={() => setFailed(true)}
          className="w-full max-h-80 object-contain transition-transform duration-500 group-hover:scale-[1.02]" />
        <span className="absolute bottom-3 right-3 inline-flex items-center gap-1.5 rounded-full bg-black/70 text-white text-xs px-3 py-1.5 backdrop-blur opacity-0 group-hover:opacity-100 transition-opacity">
          <Maximize2 className="w-3.5 h-3.5" /> Enlarge
        </span>
      </button>

      <AnimatePresence>
        {zoom && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setZoom(false)}
            className="fixed inset-0 z-[80] bg-black/85 backdrop-blur-sm flex items-center justify-center p-4 sm:p-10">
            <motion.img src={url} alt="Payment receipt (enlarged)" referrerPolicy="no-referrer"
              initial={{ scale: 0.92, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.95, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 300, damping: 28 }}
              onClick={(e) => e.stopPropagation()} className="max-w-full max-h-full rounded-2xl shadow-elev object-contain" />
            <div className="absolute top-4 right-4 flex gap-2" onClick={(e) => e.stopPropagation()}>
              <a href={url} target="_blank" rel="noreferrer" aria-label="Open original"
                className="w-10 h-10 rounded-full bg-white/15 hover:bg-white/25 text-white flex items-center justify-center transition-colors"><ExternalLink className="w-5 h-5" /></a>
              <button onClick={() => setZoom(false)} aria-label="Close"
                className="w-10 h-10 rounded-full bg-white/15 hover:bg-white/25 text-white flex items-center justify-center transition-colors"><X className="w-5 h-5" /></button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
