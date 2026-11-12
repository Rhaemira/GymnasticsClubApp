# Security policy

## Supported development line

Security fixes should target the active engineering branch and be proposed through a pull request. Do not include exploit details in public issues.

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting feature for this repository if it is enabled. If it is unavailable, contact the repository maintainer privately through GitHub before disclosing details publicly.

Include the affected version/commit, impact, reproduction steps, and any safe proof-of-concept needed to assess the issue. Do not include real user data, passwords, access tokens, or production secrets.

## Client security notes

- Authentication tokens are stored using the iOS Keychain abstraction.
- Use HTTPS for production API traffic.
- Never log or commit passwords, bearer tokens, signing credentials, or private endpoints.
- Treat API responses as untrusted input and keep authorization enforcement on the server.
