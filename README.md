# Gymnastics Club — iOS

SwiftUI client for the Gymnastics Club management API. The app requires an administrator account and communicates with the Swift/Vapor backend.

## Features

- Administrator sign-in with Keychain-backed bearer token storage
- Dashboard statistics and recent attendance
- Athlete, coach and class management
- Attendance creation and editing
- Enrollment management with class capacity visibility
- Backend-powered analytics
- Feature-colored floating tab navigation
- Light/dark appearance, Dynamic Type-friendly controls and accessibility labels

## Requirements

- Xcode 26.5 or newer
- iOS 26.5 deployment target
- The companion [GymnasticsClubBackend](https://github.com/Rhaemira/GymnasticsClubBackend) and PostgreSQL

## Xcode setup

The application bundle identifier is `com.rhaemira.GymnasticsClubApp`.

1. Clone this repository and open `GymnasticsClubApp.xcodeproj`.
2. Select the `GymnasticsClubApp` scheme.
3. Run on an iOS Simulator. Debug configuration defaults to `http://127.0.0.1:8080`; start the backend locally first.
4. Sign in using the administrator account created by the backend's `Scripts/create-admin.sh`.

### Physical iPhone

`127.0.0.1` on an iPhone refers to the phone itself, not your Mac. Configure the Debug build setting `API_BASE_URL` to a reachable development API hostname/IP and use a trusted HTTPS certificate. Do not disable App Transport Security to work around certificate errors. Grant local network access if iOS prompts for it.

### Production

Release builds set `APP_ENVIRONMENT=production` and reject non-HTTPS API URLs. Set the Xcode user-defined build setting `API_BASE_URL` to your production HTTPS endpoint before archiving:

```text
API_BASE_URL = https://api.your-domain.example
```

Do not commit production URLs containing credentials, tokens or private information.

## Architecture

- `RootView`: authentication gate and five-tab shell
- `Core/DesignSystem`: feature colors, reusable components and floating tab island
- `Core/Networking`: injectable URLSession client, API endpoints, typed errors and Keychain token storage
- `Features`: dashboard, athletes, coaches, classes, attendance, analytics and enrollment management
- `Models`: Codable API request/response models

The tab shell keeps each tab's navigation stack alive while switching tabs. The server remains authoritative for validation and business rules.

## API contract

The client uses the backend's `/auth/login`, `/auth/me`, `/auth/logout`, `/athletes`, `/coaches`, `/classes`, `/enrollments`, `/attendance`, `/reports` and `/analytics` endpoints. Business endpoints send the bearer token from Keychain. Class creation encodes `coachID` as `coach_id`; enrollment uses `athlete_id` and `class_id`.

## Build

```bash
xcodebuild -project GymnasticsClubApp.xcodeproj \
  -scheme GymnasticsClubApp \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  API_BASE_URL=https://api.example.invalid \
  build
```

## Testing

The `GymnasticsClubAppTests` XCTest target verifies request JSON keys, enrollment payloads, ISO-8601 timestamps with and without fractional seconds, production URL policy, typed network errors and endpoint paths.

Run the tests on an installed iOS Simulator:

```bash
xcodebuild test \
  -project GymnasticsClubApp.xcodeproj \
  -scheme GymnasticsClubApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  API_BASE_URL=https://api.example.invalid
```

GitHub Actions builds the app for the Simulator and runs the XCTest target. UI automation against a live backend remains a separate release-certification step.

## Screenshots

Screenshots are intentionally not included until they can be captured from the current app running against a real backend; do not use mock or stale screenshots as release evidence.
