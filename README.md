# أثر (Athar)

Libyan digital charity platform — Flutter mobile app for donors.

## Overview

Athar connects **donors** with verified **charities** running transparent
**campaigns**. The Flutter mobile app primarily serves donors; charity and
admin interfaces are designed as separate applications/web dashboards using
the same backend.

## Quick Start

```bash
flutter pub get
flutter run
```

The app runs in **Mock Mode** by default (`bool isMock = true` in
`lib/main.dart`) — no Firebase, backend, database, payment gateway or SMS
provider is required. A developer can clone the project and experience the
complete donation flow with demo data.

## Mock Mode vs API Mode

| | Mock Mode (`isMock = true`) | API Mode (`isMock = false`) |
|---|---|---|
| Data | In-memory demo data | Athar backend REST API |
| Auth | OTP is always `1234` | Real OTP via SMS |
| Payments | Simulated gateway | Backend payment endpoint |
| Storage | SharedPreferences | Secure keychain (tokens) |
| Setup | None required | Backend + credentials |

The UI layer never knows which mode is active — repositories and services
are swapped in `AppDependencies` only.

## Architecture

```
lib/
├── main.dart                  # isMock switch + app bootstrap
├── app_shell.dart             # Root shell with bottom navigation
├── core/
│   ├── localization/          # AppStrings (AR/EN), locale controller
│   ├── routing/               # AppRoutes + AppRouter
│   ├── theme/                 # Colors, typography, spacing, radius
│   ├── utils/                 # Formatters
│   └── widgets/               # Shared widgets (AppCard, StateView, ...)
├── data/
│   ├── api/                   # ApiClient, ApiConfig, ApiEndpoints, ApiError
│   ├── config/                # Environment config (dev/staging/prod)
│   ├── di/                    # AppDependencies (single DI container)
│   ├── mock/                  # Demo data
│   ├── models/                # Domain models (toJson/fromJson)
│   ├── repositories/          # Contracts + mock_* + api_* implementations
│   └── services/              # Payment, receipts, observability, ...
└── features/                  # Feature folders (presentation/ + cubits)
```

## Platform Ecosystem (Phase 5)

### Actors

1. **Donor** — the Flutter mobile app.
2. **Charity** — separate dashboard (app/web) using the same backend.
3. **Platform Administrator** — admin dashboard for approvals & monitoring.

### Campaign Lifecycle

A charity **cannot publish a campaign directly** — it must pass platform
review:

```
draft → submitted → underReview → approved → published
                                             ↓
                                    completed / suspended / rejected
```

Only `published` campaigns are visible to donors.

### Beneficiary Management

Models for `Beneficiary`, `Need`, `BeneficiaryDocument` and `SupportRecord`
with case categories (medical, food, housing, education, debt relief,
orphans, emergency) and verification status.

**Sensitive beneficiary information is never exposed publicly** — the API
layer only returns records to authorized roles. Public campaign pages show
aggregated counts only.

### Transparency

Campaigns expose target/collected/remaining amounts, donor count,
beneficiary count and status, plus a progress history
(`CampaignTransparency`).

### Platform Statistics

Public aggregated stats: total & monthly donations, donor count, campaign
count, charity count, beneficiary count, successful campaigns.

### Fraud & Security

- Client-side rate limiting (`RateLimiter`) — the backend enforces the
  authoritative policy.
- Fraud heuristics (`FraudDetector`): duplicate donation detection, unusual
  amount flags.
- Audit logs (`AuditLogEntry`) — never contain credentials.
- Device/session management (`DeviceSession`).
- Sensitive data redaction before logging (`SensitiveDataRedactor`).

### Reporting

Structured `Report` models (donation/campaign/charity, monthly/annual) and
`DonationReceipt`. The backend can render PDF/Excel variants; the app
consumes structured rows.

### Push Notifications

Provider-agnostic `NotificationService` — the UI never hardcodes a push
provider. Notification types: donation confirmation, campaign updates,
campaign completion, recurring donation, security alerts, system
announcements.

### Observability

`ObservabilityService` abstraction for crash reporting, analytics, API
logging and error monitoring. **Never logs** passwords, OTPs, card
information, CVV or authentication tokens.

### Environment Configuration

`lib/data/config/app_environment.dart` — development/staging/production
config for API base URLs, logging, analytics and notifications. **No
secrets are committed**; credentials are injected at build/deploy time.

## Security Notes

- Tokens are stored in the platform keychain via `flutter_secure_storage`.
- Payment data (card numbers, CVV, PIN) is never stored or logged.
- Audit logs and observability redact sensitive values.
- Beneficiary personal data is authorization-gated.

## Tests

```bash
flutter test
flutter analyze
```

- `test/widget_test.dart` — mock mode flow + onboarding.
- `test/phase4_api_test.dart` — API client, repositories, serialization.
- `test/phase5_platform_test.dart` — lifecycle, beneficiaries, stats,
  reports, security, observability, notifications, environment config.

## Roadmap

- Charity dashboard (separate app/web).
- Admin dashboard (user management, campaign approval, monitoring).
- Real payment provider integration (Libyan providers).
- Push notification provider integration.
- PDF/Excel report rendering.
