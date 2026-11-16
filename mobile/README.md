# EthioMarket — Mobile App

Flutter mobile app for Ethiopian import-sourcing marketplace. Buyers create requests and receive quotes from verified importers. Importers browse requests, submit quotations, advance orders. Admins operate the console.

## Roles

| Role | Who | Main flows |
|------|-----|------------|
| **Buyer** | Individuals & businesses who want imported products | Register → create request with images → compare quotations (contact hidden pre-accept) → accept → pay (manual evidence) → track order → confirm receipt → review / dispute |
| **Importer** | Verified importers | Submit verification → browse requests → submit quotation → advance order → post shipment events → manage profile |

Admin role is mobile **view-only** (opens login again) — the operations console is the React admin dashboard.

## Run

```bash
flutter pub get
cp .env.example .env      # set API_BASE_URL to your backend
flutter run