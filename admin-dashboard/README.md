# EthioMarket — Admin Dashboard

React + TypeScript + Tailwind + Framer Motion console for the Ethiopian
import-sourcing marketplace.

## Run

```bash
cp .env.example .env       # VITE_API_BASE_URL=http://localhost:5000/api/v1
npm install
npm run dev                # http://localhost:5173

---

## 📐 Styles + Types + Lib

### `src/styles/index.css`
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html { -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; }
  body { @apply bg-ink-50 text-ink-900 font-sans; }
  ::selection { @apply bg-emerald-200 text-emerald-900; }
}

@layer utilities {
  .glass { @apply backdrop-blur-lg bg-white/70 border border-white/40; }
  .text-balance { text-wrap: balance; }
  .scrollbar-thin { scrollbar-width: thin; scrollbar-color: theme('colors.ink.300') transparent; }
  .line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
}