---
name: gdpr-compliant
description: "Apply GDPR-aligned engineering practices: data minimization, retention, deletion, logging hygiene, and privacy-by-design. Use when handling personal data or adding analytics/auth flows."
---

# GDPR-Compliant Engineering (practical)

This skill provides a pragmatic privacy-by-design checklist for features that touch personal data.

## When to use

- Adding or changing user profile fields
- Implementing chat, messaging, or notifications
- Adding analytics, error reporting, or logging
- Designing data export / delete-account flows

## Checklist

### Data minimization

- Collect only what the feature needs.
- Avoid storing raw data that can be derived.

### Retention & deletion

- Define how data is deleted (account deletion or request-based deletion).
- Avoid “forever logs” containing personal data.

### Logging hygiene

- Do not log tokens, passwords, message contents, or PII.
- Prefer structured logs with redaction.

### Access control

- Ensure user data access is scoped to the authenticated user.
- Validate RLS policies and server/client responsibilities.

## Output

Provide:
- Risks (what could violate privacy expectations)
- Concrete remediation steps (code + config)
- Documentation notes (what to state in privacy policy / store listing)

## Source

Inspired by the awesome-copilot skill:
https://github.com/github/awesome-copilot/tree/main/skills/gdpr-compliant
