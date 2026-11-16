export type PaymentStatus = 'submitted' | 'verified' | 'rejected' | 'reversed' | 'disputed';

export interface PaymentRecord {
  _id: string;
  order: string | { _id: string; referenceNumber: string; status: string; totalPriceETB: number };
  buyer: string | { _id: string; fullName: string; email: string; phone: string };
  transactionReference: string;
  amountETB: number;
  paymentChannel: string;
  paidAt: string;
  receiptKey?: string | null;
  receiptUrl?: string | null;
  status: PaymentStatus;
  isVerified: boolean;
  rejectionReason?: string;
  reviewedBy?: { fullName: string; email: string } | null;
  reviewedAt?: string | null;
  reviewHistory: {
    action: string;
    actor: string;
    actorRole: string;
    note?: string;
    at: string;
  }[];
  createdAt: string;
}