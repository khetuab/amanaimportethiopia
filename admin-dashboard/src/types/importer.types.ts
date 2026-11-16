import { UserPublic } from "./user.types";

export type VerificationStatus =
  | 'pending'
  | 'approved'
  | 'rejected'
  | 'suspended'
  | 'expired';

export interface ImporterProfile {
  _id: string;
  businessName: string;
  businessType: 'individual' | 'company' | 'partnership';
  tinNumber?: string | null;
  businessLicenseNumber?: string | null;
  description?: string;
  serviceAreas: string[];
  verificationStatus: VerificationStatus;
  verificationNotes?: string;
  ratingAverage: number;
  ratingCount: number;
  completedOrdersCount: number;
  verifiedAt?: string | null;
  createdAt: string;
  user?: UserPublic & { _id: string };
}

export interface VerificationDocument {
  _id: string;
  type: string;
  label?: string;
  fileUrl: string;
  mimeType: string;
  size: number;
  isApproved: boolean | null;
  createdAt: string;
}