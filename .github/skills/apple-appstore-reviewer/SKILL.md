---
name: apple-appstore-reviewer
description: "Review iOS App Store readiness for a Flutter app: Info.plist, privacy, entitlements, login requirements, and rejection-risk checklist. Use when preparing an iOS release or investigating App Store review issues."
---

# Apple App Store Reviewer (Flutter)

Use this skill to audit the repository for common Apple App Store rejection risks and “paper cuts” before submitting.

## When to use

- Preparing an iOS App Store submission
- You received an App Store rejection and need a structured remediation checklist
- You changed permissions, tracking, login flows, subscriptions, or onboarding

## Constraints (Windows-friendly)

- iOS builds cannot be produced on Windows. This skill focuses on **static repo inspection**:
  - `ios/Runner/Info.plist`
  - entitlements / capabilities
  - privacy-sensitive code paths
  - dependency usage and disclosure

## Audit workflow

### 1) App metadata & permissions

- Inspect `ios/Runner/Info.plist` for usage descriptions (e.g., camera/photos/location) and ensure they:
  - exist only if required
  - are accurate and user-friendly
  - match actual runtime behavior

### 2) Privacy expectations

- Identify any collection of personal data (profiles, pets, chat, photos, location).
- Ensure you can explain:
  - what data is collected
  - why it is collected
  - how long it is kept
  - how a user can request deletion (if applicable)

### 3) Login & account flows

- If the app requires login, ensure:
  - the login experience is robust
  - password reset exists (if password auth is used)
  - a “delete account” / “request deletion” path exists if required by policy

### 4) Purchases / subscriptions (if present)

- Detect any purchase/subscription flows.
- Ensure you’re using Apple-compliant billing where required.

### 5) Content & moderation

- For user-generated content (feeds, chat):
  - ensure abuse reporting / blocking patterns exist or are planned
  - avoid disallowed content and provide moderation mechanisms

## Output

Produce a short report with:
- High-risk items (likely rejection)
- Medium-risk items
- Low-risk polish
- Exact file paths + recommended edits

## Source

Inspired by the awesome-copilot skill:
https://github.com/github/awesome-copilot/tree/main/skills/apple-appstore-reviewer
