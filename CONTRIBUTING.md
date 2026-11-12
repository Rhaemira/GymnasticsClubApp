# Contributing

Thanks for helping improve Gymnastics Club for iOS.

## Development setup

1. Use the Xcode version and iOS SDK stated in the README.
2. Clone the companion backend and follow its setup guide.
3. Open `GymnasticsClubApp.xcodeproj` and use the shared `GymnasticsClubApp` scheme.
4. Set `API_BASE_URL` to a reachable development endpoint. Never commit credentials or local environment files.

## Branches and pull requests

- Base work on the active engineering branch when collaborating on the current overhaul; do not push directly to `main`.
- Keep changes focused and use descriptive commit messages.
- Explain the user-visible behavior and architectural reason for a change.
- Link related backend/API changes and identify contract changes explicitly.
- Include screenshots only when captured from the current app; redact personal or sensitive data.
- Do not mark work complete until relevant checks have finished.

## Code expectations

- Follow the existing Swift formatting and feature-oriented project structure.
- Reuse shared components and networking abstractions.
- Keep view state and asynchronous work predictable; avoid blocking the main actor.
- Preserve accessibility labels, Dynamic Type behavior, and Reduce Motion support.
- Treat server validation and business rules as authoritative.
- Add or update tests for API contracts, session behavior, view-model state, and regressions.

## Validation

At minimum, build the Simulator target and run the XCTest suite using the commands in the README. For API-dependent changes, validate against a local backend as well. Report exactly which commands ran and whether they passed; do not describe queued checks as passing.
