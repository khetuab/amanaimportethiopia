export const ORDER_STATUS_OPTIONS = [
  'awaiting_payment_confirmation','payment_condition_satisfied','processing',
  'import_shipment_in_progress','customs_clearance','in_transit','ready_for_delivery',
  'delivered','completed','cancelled','disputed','refund_pending','refunded',
] as const;
export const PAYMENT_STATUS_OPTIONS = ['submitted','verified','rejected','reversed','disputed'] as const;
export const DISPUTE_STATUS_OPTIONS = ['open','under_review','resolved_buyer_favor','resolved_importer_favor','resolved_mutual','withdrawn'] as const;
export const REVENUE_STATE_OPTIONS = ['pending','invoiced','received','waived','refunded'] as const;
export const FRAUD_STATUS_OPTIONS = ['open','investigating','resolved_no_action','resolved_action_taken'] as const;
export const LEGAL_STATUS_OPTIONS = ['not_started','in_review','advice_obtained','enabled'] as const;