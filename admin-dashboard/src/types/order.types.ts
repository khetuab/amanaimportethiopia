export type OrderStatus =
  | 'awaiting_payment_confirmation'
  | 'payment_condition_satisfied'
  | 'processing'
  | 'import_shipment_in_progress'
  | 'customs_clearance'
  | 'in_transit'
  | 'ready_for_delivery'
  | 'delivered'
  | 'completed'
  | 'cancelled'
  | 'disputed'
  | 'refund_pending'
  | 'refunded';

export interface OrderItemizedCost { label: string; amountETB: number; note?: string }

export interface OrderSnapshot {
  requestReferenceNumber: string;
  quotationReferenceNumber: string;
  title: string;
  quantity: number;
  unitOfMeasurement: string;
  deliveryCity: string;
  deliveryAddress?: string;
  productCondition: string;
  specifications?: string;
  warrantyOffered?: string;
  returnPolicy?: string;
  estimatedDeliveryDays: number;
  isEstimateFinal: boolean;
  exclusions?: string;
  itemizedCosts: OrderItemizedCost[];
  importerBusinessName: string;
}

export interface OrderStatusEvent {
  from: string | null;
  to: string;
  actor?: string | null;
  actorRole?: string | null;
  note?: string;
  at: string;
}

export interface Order {
  _id: string;
  referenceNumber: string;
  buyer: string;
  importerUser: string;
  importerProfile: string;
  request: string;
  quotation: string;
  snapshot: OrderSnapshot;
  totalPriceETB: number;
  platformFeeETB: number;
  platformFeePayer: 'buyer' | 'importer';
  commissionRuleVersion?: string | null;
  status: OrderStatus;
  statusHistory: OrderStatusEvent[];
  acceptedAt: string;
  completedAt?: string | null;
  cancelledAt?: string | null;
  createdAt: string;
  buyerInfo?: { id: string; fullName: string; email: string; phone: string };
  importerInfo?: { id: string; fullName: string; email: string; phone: string };
}