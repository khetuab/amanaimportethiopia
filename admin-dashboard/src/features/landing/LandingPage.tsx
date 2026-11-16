import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowRight, ShieldCheck, Package, MessageSquare, Sparkles,
  MapPin, Truck, BadgeCheck, TrendingUp, Globe2,
} from 'lucide-react';
import { Button } from '@/components/common/Button';

/* -------------------------- Small helpers -------------------------- */

const fadeUp = {
  initial: { opacity: 0, y: 30 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, amount: 0.3 },
  transition: { duration: 0.7, ease: [0.22, 1, 0.36, 1] as const },
};

function Nav() {
  return (
    <nav className="fixed top-0 inset-x-0 z-40">
      <div className="max-w-7xl mx-auto px-6 lg:px-10 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2.5">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-emerald-400 to-emerald-700 flex items-center justify-center text-white font-bold">
            ኢ
          </div>
          <div className="leading-tight">
            <div className="font-semibold text-emerald-950">EthioMarket</div>
            <div className="text-[10px] uppercase tracking-widest text-emerald-800/70">
              Import Sourcing
            </div>
          </div>
        </Link>
        <div className="hidden md:flex items-center gap-7 text-sm text-emerald-950/80">
          <a href="#story" className="hover:text-emerald-900">Story</a>
          <a href="#how" className="hover:text-emerald-900">How it works</a>
          <a href="#trust" className="hover:text-emerald-900">Trust</a>
        </div>
        <Link to="/login">
          <Button size="sm" variant="primary">
            Admin sign in <ArrowRight className="w-4 h-4" />
          </Button>
        </Link>
      </div>
    </nav>
  );
}

function Hero() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start start', 'end start'] });
  const yBg = useTransform(scrollYProgress, [0, 1], [0, 180]);
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0.2]);
  const scale = useTransform(scrollYProgress, [0, 1], [1, 1.08]);

  return (
    <section ref={ref} className="relative h-[100svh] min-h-[680px] overflow-hidden">
      {/* Parallax gradient background */}
      <motion.div
        style={{ y: yBg, scale }}
        className="absolute inset-0 bg-[radial-gradient(1200px_600px_at_20%_20%,#065f46_0%,transparent_60%),radial-gradient(900px_500px_at_85%_30%,#022c22_0%,transparent_60%),linear-gradient(180deg,#022c22_0%,#064e3b_60%,#0f172a_100%)]"
      />
      {/* Ambient noise / pattern */}
      <div className="absolute inset-0 opacity-[0.06] bg-[repeating-linear-gradient(0deg,#fff_0,#fff_1px,transparent_1px,transparent_60px),repeating-linear-gradient(90deg,#fff_0,#fff_1px,transparent_1px,transparent_60px)]" />

      {/* Floating product silhouettes */}
      <FloatingCard
        className="absolute left-[6%] top-[28%] hidden md:block"
        delay={0.1}
        icon={<Package className="w-5 h-5" />}
        title="MacBook Pro 14"
        sub="Sourced from Shenzhen"
      />
      <FloatingCard
        className="absolute right-[8%] top-[16%] hidden lg:block"
        delay={0.3}
        icon={<Truck className="w-5 h-5" />}
        title="In transit"
        sub="ETA 8 days · customs cleared"
      />
      <FloatingCard
        className="absolute right-[16%] bottom-[20%] hidden lg:block"
        delay={0.5}
        icon={<BadgeCheck className="w-5 h-5" />}
        title="Verified importer"
        sub="Ras Trading · 4.9 ★"
      />

      <motion.div
        style={{ opacity }}
        className="relative z-10 max-w-7xl mx-auto px-6 lg:px-10 h-full flex flex-col justify-center"
      >
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-900/60 border border-emerald-700/50 text-emerald-200 text-xs w-fit"
        >
          <Sparkles className="w-3.5 h-3.5 text-gold-300" />
          Ethiopia's import-sourcing marketplace — operated with verified partners
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.9, delay: 0.1 }}
          className="mt-6 text-white font-display text-[clamp(2.5rem,6vw,5rem)] leading-[1.02] max-w-4xl text-balance"
        >
          Ask for anything.
          <br />
          <span className="bg-gradient-to-r from-gold-200 via-gold-300 to-gold-500 bg-clip-text text-transparent">
            Verified importers deliver.
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.25 }}
          className="mt-6 max-w-xl text-emerald-50/80 text-lg"
        >
          Post a request for any imported product — a phone, a spare part, a machine.
          Approved importers compete with transparent offers. You choose.
          Every step is tracked, reviewed, and settled on agreed terms.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="mt-8 flex flex-wrap gap-3"
        >
          <Link to="/login">
            <Button size="lg" variant="gold">
              Enter admin console <ArrowRight className="w-4 h-4" />
            </Button>
          </Link>
          <a href="#story">
            <Button size="lg" variant="secondary" className="!bg-white/10 !text-white !border-white/20 hover:!bg-white/20">
              See the story
            </Button>
          </a>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.9 }}
          className="mt-14 grid grid-cols-3 gap-6 max-w-2xl"
        >
          {[
            { k: '10+', v: 'Product categories' },
            { k: 'ETB', v: 'Local currency pricing' },
            { k: '24/7', v: 'Admin oversight' },
          ].map((s) => (
            <div key={s.v}>
              <div className="text-white font-display text-2xl">{s.k}</div>
              <div className="text-emerald-200/70 text-sm mt-1">{s.v}</div>
            </div>
          ))}
        </motion.div>
      </motion.div>

      {/* scroll hint */}
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 1.4 }}
        className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 text-emerald-200/80 text-xs tracking-widest uppercase"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
        >
          scroll
        </motion.div>
      </motion.div>
    </section>
  );
}

function FloatingCard({
  className = '', delay = 0, icon, title, sub,
}: {
  className?: string; delay?: number; icon: React.ReactNode; title: string; sub: string;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8, delay }}
      className={`z-10 ${className}`}
    >
      <motion.div
        animate={{ y: [0, -10, 0] }}
        transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
        className="glass rounded-2xl p-4 flex items-center gap-3 w-64 shadow-elev"
      >
        <div className="w-10 h-10 rounded-xl bg-emerald-600 text-white flex items-center justify-center">
          {icon}
        </div>
        <div className="min-w-0">
          <div className="text-emerald-950 font-medium truncate">{title}</div>
          <div className="text-xs text-emerald-800/70 truncate">{sub}</div>
        </div>
      </motion.div>
    </motion.div>
  );
}

function Story() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start end', 'end start'] });
  const y1 = useTransform(scrollYProgress, [0, 1], [0, -60]);
  const y2 = useTransform(scrollYProgress, [0, 1], [0, -140]);
  const rotate = useTransform(scrollYProgress, [0, 1], [0, 8]);

  const chapters = [
    {
      n: 'I',
      title: 'Ask for what you need',
      body:
        'A shop owner in Merkato needs a specific brake pad. A student wants a laptop. A farmer needs a pump. They post a request — no shipping forms, no currency confusion, no phone numbers hunted online.',
    },
    {
      n: 'II',
      title: 'Verified importers compete',
      body:
        'Approved importers — with real business licences, TINs, and import history — browse requests across ten categories. They submit transparent itemized quotes: product, shipping, customs (estimated or confirmed), and warranty terms.',
    },
    {
      n: 'III',
      title: 'You choose the best fit',
      body:
        'Compare side-by-side: price, delivery window, warranty, product condition, verified reputation. The platform fee is shown before you accept — always.',
    },
    {
      n: 'IV',
      title: 'Every step, tracked',
      body:
        'Payment evidence is reviewed by an admin. Shipment events are logged as they happen. Delivery is confirmed. Only then can the order complete. Disputes have a timeline, evidence, and an admin ruling.',
    },
  ];

  return (
    <section id="story" ref={ref} className="relative py-32 bg-white overflow-hidden">
      <motion.div
        style={{ y: y1 }}
        className="absolute -top-20 left-1/2 -translate-x-1/2 w-[800px] h-[800px] rounded-full bg-emerald-100/40 blur-3xl"
      />
      <div className="relative max-w-5xl mx-auto px-6 lg:px-10">
        <motion.div {...fadeUp} className="max-w-2xl">
          <div className="text-xs uppercase tracking-[0.2em] text-emerald-700">The story</div>
          <h2 className="mt-4 font-display text-4xl md:text-5xl text-emerald-950 leading-[1.05] text-balance">
            Four chapters from wish to delivery.
          </h2>
        </motion.div>

        <div className="mt-16 grid md:grid-cols-2 gap-x-12 gap-y-16">
          {chapters.map((c, i) => (
            <motion.div
              key={c.n}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.4 }}
              transition={{ duration: 0.7, delay: i * 0.08 }}
              className="relative"
            >
              <motion.div
                style={{ rotate: i % 2 ? rotate : 0 }}
                className="absolute -top-8 -left-2 font-display text-[7rem] leading-none text-emerald-900/[0.07] select-none"
              >
                {c.n}
              </motion.div>
              <div className="relative">
                <div className="text-xs font-medium text-emerald-700 tracking-widest uppercase mb-2">
                  Chapter {c.n}
                </div>
                <h3 className="font-display text-2xl text-emerald-950">{c.title}</h3>
                <p className="mt-3 text-ink-700/80 leading-relaxed">{c.body}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      <motion.div style={{ y: y2 }} className="absolute bottom-0 right-0 w-72 h-72 rounded-full bg-gold-200/30 blur-3xl" />
    </section>
  );
}

function HowItWorks() {
  const steps = [
    { icon: Package, title: 'Post a request', body: 'Detailed specs, reference images, budget, delivery city and deadline.' },
    { icon: MessageSquare, title: 'Receive quotes', body: 'Approved importers offer itemized prices, warranty, and delivery windows.' },
    { icon: ShieldCheck, title: 'Accept with clarity', body: 'See the platform fee and total cost before you commit. One click creates a tracked order.' },
    { icon: Truck, title: 'Track & receive', body: 'Shipment events, customs, delivery — logged and visible. Confirm, review, done.' },
  ];
  return (
    <section id="how" className="relative py-28 bg-ink-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <motion.div {...fadeUp} className="max-w-2xl">
          <div className="text-xs uppercase tracking-[0.2em] text-emerald-700">How it works</div>
          <h2 className="mt-4 font-display text-4xl md:text-5xl text-emerald-950 leading-[1.05] text-balance">
            A calm workflow for a complicated world.
          </h2>
        </motion.div>
        <div className="mt-14 grid md:grid-cols-4 gap-6">
          {steps.map((s, i) => (
            <motion.div
              key={s.title}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.4 }}
              transition={{ duration: 0.6, delay: i * 0.08 }}
              className="p-6 rounded-2xl bg-white border border-ink-200 shadow-card hover:shadow-elev transition-shadow"
            >
              <div className="w-11 h-11 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
                <s.icon className="w-5 h-5" />
              </div>
              <div className="mt-4 text-xs text-emerald-700 font-medium">Step {i + 1}</div>
              <h3 className="mt-1 font-semibold text-emerald-950">{s.title}</h3>
              <p className="mt-2 text-sm text-ink-600 leading-relaxed">{s.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Trust() {
  const points = [
    { icon: BadgeCheck, title: 'Verified importers', body: 'Licences, TIN, and identity documents reviewed before approval. Suspension is a real, audited action.' },
    { icon: ShieldCheck, title: 'Manual payment review', body: 'Evidence is never auto-trusted. An administrator verifies every payment reference against the approved channel.' },
    { icon: TrendingUp, title: 'Transparent fees', body: 'The platform fee, its payer, and the rule version are shown before acceptance and locked into the order snapshot.' },
    { icon: Globe2, title: 'Ethiopia-first', body: 'ETB pricing, Ethiopian addresses, local phone formats, and English/Amharic-ready architecture.' },
    { icon: MapPin, title: 'Delivery to your city', body: 'Addis, Adama, Bahir Dar, Hawassa, Mekelle — delivery city is agreed at quotation time.' },
    { icon: MessageSquare, title: 'In-app messaging', body: 'Buyer↔importer conversations tied to a specific order. Admins can review conversations for dispute resolution.' },
  ];
  return (
    <section id="trust" className="relative py-28 bg-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <motion.div {...fadeUp} className="max-w-2xl">
          <div className="text-xs uppercase tracking-[0.2em] text-emerald-700">Trust</div>
          <h2 className="mt-4 font-display text-4xl md:text-5xl text-emerald-950 leading-[1.05] text-balance">
            Trust is the product.
          </h2>
          <p className="mt-4 text-ink-600">
            Every safeguard below is not a promise — it's code running in the backend today.
          </p>
        </motion.div>

        <div className="mt-14 grid md:grid-cols-3 gap-6">
          {points.map((p, i) => (
            <motion.div
              key={p.title}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.3 }}
              transition={{ duration: 0.6, delay: i * 0.06 }}
              className="p-6 rounded-2xl bg-gradient-to-br from-white to-emerald-50/40 border border-ink-200"
            >
              <div className="w-11 h-11 rounded-xl bg-emerald-900 text-white flex items-center justify-center">
                <p.icon className="w-5 h-5" />
              </div>
              <h3 className="mt-4 font-semibold text-emerald-950">{p.title}</h3>
              <p className="mt-2 text-sm text-ink-600 leading-relaxed">{p.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="bg-emerald-950 text-emerald-100 py-16">
      <div className="max-w-7xl mx-auto px-6 lg:px-10 grid md:grid-cols-4 gap-10">
        <div className="md:col-span-2">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center text-emerald-950 font-bold">
              ኢ
            </div>
            <div className="font-semibold">EthioMarket</div>
          </div>
          <p className="mt-4 text-sm text-emerald-200/70 max-w-md leading-relaxed">
            An Ethiopian import-sourcing marketplace connecting buyers with verified
            importers. Every step is tracked, every action audited, every payment reviewed.
          </p>
        </div>
        <div>
          <div className="text-xs uppercase tracking-widest text-emerald-400 mb-3">Platform</div>
          <div className="space-y-2 text-sm text-emerald-200/80">
            <div>Categories</div>
            <div>Request flow</div>
            <div>Quotations</div>
            <div>Order tracking</div>
          </div>
        </div>
        <div>
          <div className="text-xs uppercase tracking-widest text-emerald-400 mb-3">Operations</div>
          <div className="space-y-2 text-sm text-emerald-200/80">
            <Link to="/login" className="hover:text-white">Admin console</Link>
            <div>Fraud reporting</div>
            <div>Legal checklist</div>
          </div>
        </div>
      </div>
      <div className="mt-14 border-t border-emerald-900/60">
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-6 text-xs text-emerald-300/60 flex flex-wrap justify-between gap-3">
          <span>© {new Date().getFullYear()} EthioMarket PLC. All rights reserved.</span>
          <span>Operated in Ethiopia. Manual payments require legal review.</span>
        </div>
      </div>
    </footer>
  );
}

export default function LandingPage() {
  return (
    <div className="bg-white">
      <Nav />
      <Hero />
      <Story />
      <HowItWorks />
      <Trust />
      <Footer />
    </div>
  );
}