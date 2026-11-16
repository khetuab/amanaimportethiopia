export interface QuotationSummary {
  _id: string;
  referenceNumber: string;
  totalPriceETB: number;
  status: string;
  productCondition: string;
  estimatedDeliveryDays: number;
  importerProfile?: { businessName?: string; ratingAverage?: number; ratingCount?: number };
}