---
description: "OWASP-inspired secure coding rules for PetSphere (Flutter + Supabase): auth, access control, secrets, input handling."
applyTo: "**/*"
---

# Security & OWASP — PetSphere

This guidance is intentionally short and high-signal to avoid bloating context. Apply it when implementing auth flows, data access, storage, notifications, or anything touching user data.

## Non-negotiables

- **No secrets in code**: never commit API keys, service-role keys, tokens, or credentials.
- **Least privilege**: client code must only use anon/public capabilities; privileged ops belong in secure server-side components (if/when added).
- **Assume hostile input**: validate/sanitize user-provided content before storing/displaying.

## Access control

- Do not rely on UI gating for security.
- For Supabase, ensure **RLS is enabled** and policies match intended access.
- Prefer explicit query filters for performance (don’t depend solely on RLS for filtering).

## Data exposure

- Avoid logging PII (emails, phone numbers, access tokens, message contents) in production logs.
- Be careful with error messages: don’t leak sensitive details.

## Storage & uploads

- Validate file type/size.
- Use per-user paths and access rules; avoid “public by default”.

## Source

Inspired by the awesome-copilot instruction:
https://github.com/github/awesome-copilot/blob/main/instructions/security-and-owasp.instructions.md
