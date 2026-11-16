import {
  Hourglass, BadgeCheck, Cog, Ship, ClipboardCheck, Truck, PackageCheck, Home, CheckCheck,
  Gavel, Ban, Undo2, RotateCcw, type LucideIcon,
} from 'lucide-react';
import type { OrderStatus } from '@/types/order.types';

export const PIPELINE: { key: OrderStatus; label: string; icon: LucideIcon }[] = [
  { key: 'awaiting_payment_confirmation', label: 'Awaiting payment', icon: Hourglass },
  { key: 'payment_condition_satisfied', label: 'Payment cleared', icon: BadgeCheck },
  { key: 'processing', label: 'Processing', icon: Cog },
  { key: 'import_shipment_in_progress', label: 'Importing', icon: Ship },
  { key: 'customs_clearance', label: 'Customs', icon: ClipboardCheck },
  { key: 'in_transit', label: 'In transit', icon: Truck },
  { key: 'ready_for_delivery', label: 'Ready', icon: PackageCheck },
  { key: 'delivered', label: 'Delivered', icon: Home },
  { key: 'completed', label: 'Completed', icon: CheckCheck },
];

export const stageIndex = (s: OrderStatus): number => PIPELINE.findIndex((p) => p.key === s);

export const SIDE_STATES: Partial<Record<OrderStatus, { label: string; text: string; icon: LucideIcon; tone: 'red' | 'amber' | 'slate' }>> = {
  disputed: { label: 'Disputed', text: 'This order is under dispute. Normal progress is paused until it is resolved.', icon: Gavel, tone: 'red' },
  cancelled: { label: 'Cancelled', text: 'This order was cancelled and will not progress further.', icon: Ban, tone: 'slate' },
  refund_pending: { label: 'Refund pending', text: 'A refund has been approved and is waiting to be completed.', icon: Undo2, tone: 'amber' },
  refunded: { label: 'Refunded', text: 'The buyer has been refunded. This order is closed.', icon: RotateCcw, tone: 'slate' },
};
