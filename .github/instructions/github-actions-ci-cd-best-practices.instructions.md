---
description: "GitHub Actions CI/CD guidance for this repo (Flutter): least privilege, caching, and safe workflow patterns."
applyTo: ".github/workflows/*.yml,.github/workflows/*.yaml"
---

# GitHub Actions CI/CD Best Practices — Flutter

Apply these rules when creating or editing workflows in `.github/workflows/**`.

## Security

- Use least-privilege `permissions:` at workflow/job level.
- Pin third-party actions to a commit SHA when possible.
- Avoid echoing secrets; never print tokens.

## Reliability

- Keep workflows deterministic.
- Prefer explicit versions for toolchains.

## Performance

- Use caching for Flutter/pub artifacts when appropriate.
- Split CI into fast checks (analyze/test) and slower build jobs.

## Flutter checks to include

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Source

Inspired by the awesome-copilot instruction:
https://github.com/github/awesome-copilot/blob/main/instructions/github-actions-ci-cd-best-practices.instructions.md
