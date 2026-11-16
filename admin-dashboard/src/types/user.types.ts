export type Role = 'buyer' | 'importer' | 'admin';

export interface UserPublic {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  role: Role;
  status: string;
  preferredLanguage: 'en' | 'am';
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  createdAt?: string;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
}