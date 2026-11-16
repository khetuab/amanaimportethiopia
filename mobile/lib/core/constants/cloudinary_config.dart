class CloudinaryConfig {
  CloudinaryConfig._();

  // The first argument is the NAME of the define (do not change it);
  // defaultValue is used when no --dart-define is passed.
  static const cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'hbi8h9ul',
  );
  static const uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'ethio_requests',
  );

  static const requestFolder = 'ethiomarket/requests';

  static const receiptPreset = String.fromEnvironment(
    'CLOUDINARY_RECEIPT_PRESET',
    defaultValue: 'ethio_receipts',
  );
  static const receiptFolder = 'ethiomarket/receipts';
  static bool get isConfigured =>
      cloudName.isNotEmpty && uploadPreset.isNotEmpty;
}