# Gymnastics Club — iOS

[![iOS CI](https://github.com/Rhaemira/GymnasticsClubApp/actions/workflows/ios.yml/badge.svg?branch=main)](https://github.com/Rhaemira/GymnasticsClubApp/actions/workflows/ios.yml)
[![Platform](https://img.shields.io/badge/platform-iOS%20%2F%20iPadOS-147EFB)](#)
[![Swift](https://img.shields.io/badge/Swift-6-orange)](#)

A native SwiftUI application for managing a gymnastics club. It connects to the companion [Gymnastics Club Backend](https://github.com/Rhaemira/GymnasticsClubBackend), with PostgreSQL as the system of record.

> **Project status:** Active engineering work. The feature branch contains the current overhaul. CI and manual end-to-end validation should be checked before treating a build as release-ready.

## Product capabilities

- **Secure access** — administrator sign-in, bearer-token sessions, and Keychain-backed token storage.
- **Club operations** — manage athletes, coaches, classes, enrollments, and attendance.
- **At-a-glance insight** — dashboard metrics, recent activity, reports, and analytics.
- **Native interaction** — SwiftUI navigation, system list swipe actions, and queued delete/Undo behavior.
- **Accessibility and appearance** — light/dark appearance, Dynamic Type-aware controls, accessibility labels, and Reduce Motion support.

## Screens and architecture

The app is organized by feature, with shared design-system, reusable UI, networking, and model layers.

| Area | Responsibility |
|---|---|
| `Features/Authentication` | Administrator sign-in |
| `Features/Athletes` | Athlete list, detail, and forms |
| `Features/Coaches` | Coach management |
| `Features/Classes` | Class management and enrollment |
| `Features/Attendance` | Attendance list, detail, create/edit flows |
| `Features/Dashboard` and `Views` | Dashboard, reports, analytics, settings |
| `Core/Networking` | API client, endpoints, session, token storage |
| `Core/DesignSystem` | Shared visual language and components |
| `Models` | API request and response models |

Each tab owns its navigation stack. Management lists use native SwiftUI list interactions. Delete operations are staged through the Undo flow before the server mutation is finalized.

## Requirements

- Xcode 26.5 or newer
- iOS 26.5 SDK / deployment target as configured by the project
- The companion backend and a reachable API endpoint

## Quick start

1. Clone this repository and open `GymnasticsClubApp.xcodeproj`.
2. Select the shared `GymnasticsClubApp` scheme.
3. Start the backend and PostgreSQL database using the [backend setup guide](https://github.com/Rhaemira/GymnasticsClubBackend#quick-start).
4. Run on an iOS Simulator. The Debug configuration defaults to `http://127.0.0.1:8080`.
5. Sign in with an administrator account created by the backend's `Scripts/create-admin.sh`.

### Configure the API URL

Set the Xcode user-defined build setting `API_BASE_URL` to the address reachable from the device.

- **Simulator:** `http://127.0.0.1:8080` when the API runs on the same Mac.
- **Physical device:** use your Mac's LAN hostname/IP or a development HTTPS endpoint. On an iPhone, `127.0.0.1` refers to the phone itself.
- **Release:** configure a trusted HTTPS endpoint. Production builds reject non-HTTPS API URLs.

Do not disable App Transport Security to work around certificate errors. Do not commit private API URLs, credentials, or tokens.

## Build and test

Build for the generic iOS Simulator:

```bash
xcodebuild \
  -project GymnasticsClubApp.xcodeproj \
  -scheme GymnasticsClubApp \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  API_BASE_URL=https://api.example.invalid \
  build
```

Run the XCTest target on an installed simulator:

```bash
xcodebuild test \
  -project GymnasticsClubApp.xcodeproj \
  -scheme GymnasticsClubApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  API_BASE_URL=https://api.example.invalid
```

The test target covers API payload contracts, authentication/session behavior, enrollment and management view models, networking, and Undo coordination. GitHub Actions builds the simulator app and runs the XCTest target. UI automation against a live backend and physical-device validation are separate release-certification tasks.

## API integration

The client integrates with the backend's authentication, athlete, coach, class, enrollment, attendance, reports, and analytics endpoints. Authenticated requests use the bearer token held by the session/token-store layer. The API contract and server setup are documented in the [backend repository](https://github.com/Rhaemira/GymnasticsClubBackend).

## Engineering principles

- Keep API request/response models aligned with the backend contract.
- Keep secrets and session tokens out of source control, logs, screenshots, and issue reports.
- Prefer native SwiftUI behavior and shared components over parallel one-off implementations.
- Cover networking and state transitions with deterministic tests.
- Preserve user data; do not use destructive migrations or unverified mock screenshots as release evidence.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch, code, testing, and pull-request expectations. Security concerns belong in [SECURITY.md](SECURITY.md), not public issue reports.

## Related project

- [GymnasticsClubBackend](https://github.com/Rhaemira/GymnasticsClubBackend) — Swift/Vapor API, PostgreSQL schema, authentication, and deployment tooling.
