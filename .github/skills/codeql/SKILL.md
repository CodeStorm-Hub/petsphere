---
name: codeql
description: "Set up or troubleshoot GitHub CodeQL scanning (GitHub Actions) for this repo. Use when adding code scanning workflows, fixing CodeQL CI failures, or interpreting CodeQL alerts."
---

# CodeQL (GitHub Actions)

Use this skill to add or maintain CodeQL scanning for the repository.

## When to use

- “Set up CodeQL scanning”
- “Why is CodeQL failing in CI?”
- “How do we run code scanning on pull requests?”
- “Interpret/fix this CodeQL alert”

## Workflow

1) **Discover repository languages**
   - Check `pubspec.yaml`, `android/`, `ios/`, and any scripts to understand what CodeQL packs apply.

2) **Add or update workflow**
   - Create/update `.github/workflows/codeql.yml`.
   - Use least-privilege permissions.

3) **Tune triggers**
   - Run on `push` to `main` and on `pull_request`.
   - Consider scheduled runs (e.g., weekly).

4) **Triage alerts**
   - Classify: true positive / false positive / needs more context.
   - Provide a concrete fix or suppression rationale.

## Notes for Flutter repos

- CodeQL is most effective when there’s analyzable source in supported languages (e.g., Java/Kotlin, Swift/Obj-C, JS, etc.).
- Even if Dart isn’t fully covered, CodeQL can still help with platform directories or scripts.

## Source

Inspired by the awesome-copilot skill:
https://github.com/github/awesome-copilot/tree/main/skills/codeql
