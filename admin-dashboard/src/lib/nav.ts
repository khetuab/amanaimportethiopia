import {
  LayoutDashboard, BadgeCheck, CreditCard, Package, Scale, Tags, ClipboardList,
  FileSignature, Percent, Landmark, ScrollText, ShieldCheck, Users, ShieldAlert,
  type LucideIcon,
} from 'lucide-react';

export type BadgeKey = 'pendingImporters' | 'openDisputes';

export interface NavItem {
  to: string;
  label: string;
  hint: string;
  icon: LucideIcon;
  end?: boolean;
  badge?: BadgeKey;
}
export interface NavSection { title: string; items: NavItem[] }

export const NAV_SECTIONS: NavSection[] = [
  {
    title: 'Operations',
    items: [
      { to: '/admin', label: 'Dashboard', hint: 'Live marketplace snapshot', icon: LayoutDashboard, end: true },
      { to: '/admin/importers', label: 'Importers', hint: 'Verify licenses and control who may quote', icon: BadgeCheck, badge: 'pendingImporters' },
      { to: '/admin/payments', label: 'Payments', hint: 'Review manual payment evidence', icon: CreditCard },
      { to: '/admin/orders', label: 'Orders', hint: 'Track every accepted quotation', icon: Package },
      { to: '/admin/disputes', label: 'Disputes', hint: 'Resolve conflicts between parties', icon: Scale, badge: 'openDisputes' },
      { to: '/admin/fraud', label: 'Fraud reports', hint: 'Triage suspicious activity', icon: ShieldAlert },
    ],
  },
  {
    title: 'Catalog',
    items: [
      { to: '/admin/categories', label: 'Categories', hint: 'Configure product categories', icon: Tags },
      { to: '/admin/requests', label: 'Requests', hint: 'Browse all buyer requests', icon: ClipboardList },
      { to: '/admin/quotations', label: 'Quotations', hint: 'Monitor importer offers', icon: FileSignature },
    ],
  },
  {
    title: 'Finance',
    items: [
      { to: '/admin/commissions/rules', label: 'Commission rules', hint: 'Versioned fee rules', icon: Percent },
      { to: '/admin/commissions/reconciliation', label: 'Reconciliation', hint: 'Earned, invoiced, received', icon: Landmark },
    ],
  },
  {
    title: 'Oversight',
    items: [
      { to: '/admin/audit', label: 'Audit log', hint: 'Every privileged action', icon: ScrollText },
      { to: '/admin/settings', label: 'Legal checklist', hint: 'Compliance tracking', icon: ShieldCheck },
      { to: '/admin/users', label: 'Users', hint: 'Your administrator profile', icon: Users },
    ],
  },
];

export const ALL_NAV: NavItem[] = NAV_SECTIONS.flatMap((s) => s.items);

/** Best-effort match of a pathname to a nav item (longest prefix wins). */
export function navFor(pathname: string): NavItem | undefined {
  const clean = pathname.replace(/\/+$/, '') || '/';
  return [...ALL_NAV]
    .sort((a, b) => b.to.length - a.to.length)
    .find((n) => (n.end ? clean === n.to : clean === n.to || clean.startsWith(`${n.to}/`)));
}
