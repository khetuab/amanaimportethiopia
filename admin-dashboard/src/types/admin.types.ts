export interface ReportsSummary {
  requests: {
    total: number;
    byStatus: Record<string, number>;
    byCategory: { categoryId: string; name?: string; count: number }[];
  };
  conversions: {
    requests: number;
    quotations: number;
    orders: number;
    acceptedQuotes: number;
    avgQuotationsPerRequest: number;
    requestToQuoteRate: number;
    requestToOrderRate: number;
  };
  revenue: {
    pending: { count: number; total: number };
    invoiced: { count: number; total: number };
    received: { count: number; total: number };
    waived: { count: number; total: number };
    refunded: { count: number; total: number };
    verifiedPayments: { count: number; total: number };
  };
  disputes: {
    total: number;
    open: number;
    byStatus: Record<string, number>;
    byReason: { _id: string; count: number }[];
  };
  importers: {
    byStatus: Record<string, number>;
    top: {
      _id: string;
      businessName: string;
      completedOrdersCount: number;
      ratingAverage: number;
      ratingCount: number;
    }[];
  };
}

export interface AuditLogEntry {
  _id: string;
  actor: { _id: string; fullName: string; email: string; role: string } | string;
  actorRole: string;
  action: string;
  targetType: string;
  targetId: string;
  summary?: string;
  createdAt: string;
}

export interface FraudReport {
  _id: string;
  category: string;
  description: string;
  status: 'open' | 'investigating' | 'resolved_no_action' | 'resolved_action_taken';
  reporter?: { fullName?: string; email?: string; role?: string } | null;
  relatedUser?: { fullName?: string; email?: string; role?: string } | null;
  relatedOrder?: { referenceNumber?: string; status?: string } | null;
  adminNotes?: string;
  createdAt: string;
}

export interface LegalChecklistItem {
  _id: string;
  item: string;
  label: string;
  category: string;
  status: 'not_started' | 'in_review' | 'advice_obtained' | 'enabled';
  gatesCapability?: string | null;
  notes?: string;
  legalAdviceReference?: string;
  reviewedAt?: string | null;
}

export interface CommissionRule {
  _id: string;
  name: string;
  version: string;
  feeType: 'percentage' | 'fixed';
  percentage?: number | null;
  fixedAmountETB?: number | null;
  minFeeETB?: number | null;
  maxFeeETB?: number | null;
  payer: 'buyer' | 'importer';
  categoryIds: string[];
  effectiveFrom: string;
  effectiveUntil?: string | null;
  isActive: boolean;
  description?: string;
}

export interface CommissionRecord {
  _id: string;
  order: { _id: string; referenceNumber: string; status: string; totalPriceETB: number } | string;
  ruleVersion: string;
  feeType: string;
  payer: string;
  orderValueETB: number;
  computedFeeETB: number;
  revenueState: 'pending' | 'invoiced' | 'received' | 'waived' | 'refunded';
  createdAt: string;
}