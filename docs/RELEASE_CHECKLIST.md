# iOS release checklist

Use this checklist for a TestFlight, App Store, or internal production release. Do not treat a successful CI run as a substitute for validating the actual release configuration and backend.

## Source and build

- [ ] Confirm the release commit is the reviewed commit and the working tree is clean.
- [ ] Confirm the iOS and backend API contracts are compatible.
- [ ] Confirm the release version and build number are intentional and incremented.
- [ ] Build the Release configuration with the intended production API URL.
- [ ] Confirm the production API URL uses HTTPS and has a valid certificate chain.
- [ ] Confirm no local `.env`, credentials, tokens, signing assets, or developer-specific Xcode data are tracked.

## Automated checks

- [ ] iOS Debug Simulator build passes.
- [ ] iOS Release Simulator build passes.
- [ ] Xcode static analysis passes.
- [ ] XCTest suite passes on the supported simulator runtime.
- [ ] Companion backend Linux/PostgreSQL, native macOS, and Docker checks pass on the matching release candidate.

## Device smoke test

- [ ] Install and launch on a physical supported iPhone.
- [ ] Sign in, terminate and relaunch, and confirm session restoration.
- [ ] Verify invalid credentials, expired sessions, offline restore, and sign-out messaging.
- [ ] Navigate through all five tabs and verify independent navigation state.
- [ ] Create, edit, and delete an athlete, coach, class, enrollment, and attendance record where applicable.
- [ ] Verify Undo behavior, including switching tabs and leaving the authenticated workspace.
- [ ] Verify empty, loading, validation, server-error, and offline states.
- [ ] Check Dynamic Type, VoiceOver labels, light/dark appearance, and Reduce Motion.
- [ ] Check the app on a small iPhone and an iPad layout.

## Security and operations

- [ ] Confirm Release builds reject non-HTTPS API endpoints.
- [ ] Confirm no sensitive values appear in application logs or crash reports.
- [ ] Confirm backend secrets, database TLS, backups, and restore procedures are configured.
- [ ] Confirm the backend has shared edge rate limiting if deployed with multiple instances.
- [ ] Confirm privacy disclosures and App Store metadata match actual data collection and use.

## Sign-off

Record the commit SHA, app version/build, backend release, tested device/OS versions, CI run links, and the person approving the release. Document any known limitations; do not silently waive failed checks.