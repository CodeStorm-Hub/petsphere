# PetSphere Copilot Customizations (`.github/`)

This folder contains **GitHub Copilot customizations** for the PetSphere repo:

- **Workspace guidance**: always-on rules for how Copilot should behave here.
- **Instructions**: file-scoped “house rules” that load automatically based on `applyTo` globs.
- **Skills**: step-by-step playbooks Copilot can follow when you explicitly ask for them.
- **Agents**: specialized modes (e.g., ADR writing, implementation planning).

If you’re looking for app architecture and run commands, see:

- `README.md`
- `CODEBASE_ANALYSIS.md`

---

## How to use these

### 1) Workspace instructions (always-on)

- `copilot-instructions.md` applies to the whole repo.
- You don’t need to “invoke” it; it’s always considered when Copilot generates code here.

**File:** `copilot-instructions.md`

- Defines PetSphere architecture (Views → Controllers → Repos → Supabase)
- Enforces **no secrets** and `.env`/`--dart-define-from-file=.env`
- Riverpod Notifier rule: **return initial state in `build()`** and defer async work (avoid mutating provider state during `build()`)

### 2) Instructions (auto-loaded by file path)

Files in `.github/instructions/*.instructions.md` load automatically **only** when you’re working on matching files.

If an instruction isn’t taking effect, check:

- The YAML frontmatter is valid
- `applyTo` matches the file you’re editing

#### Installed instructions

- `instructions/context7.instructions.md` — Use authoritative external docs (Context7) when local context is insufficient.
  - **applyTo:** `**`
- `instructions/dart-n-flutter.instructions.md` — Dart/Flutter coding rules and best practices.
  - **applyTo:** `**/*.dart`

- `instructions/a11y.instructions.md` — Accessibility guidance for Flutter UI (semantics, focus, text scaling).
  - **applyTo:** `lib/**/*.dart`
  - When to expect it: editing UI in `lib/views/**` or widgets.

- `instructions/performance-optimization.instructions.md` — Flutter perf guidance (rebuilds, lists, images, async work).
  - **applyTo:** `lib/**/*.dart`

- `instructions/security-and-owasp.instructions.md` — OWASP-inspired secure coding rules for Flutter + Supabase.
  - **applyTo:** `**/*` (kept intentionally short to reduce context cost)

- `instructions/sql-sp-generation.instructions.md` — Supabase migration SQL rules (RLS-by-default, indexing, safety).
  - **applyTo:** `supabase/migrations/**/*.sql`

- `instructions/github-actions-ci-cd-best-practices.instructions.md` — CI/CD workflow best practices.
  - **applyTo:** `.github/workflows/*.yml,.github/workflows/*.yaml`

- `instructions/taming-copilot.instructions.md` — Keep diffs small and reviewable; avoid wide refactors.
  - **applyTo:** `**/*` (lightweight)

### 3) Skills (explicitly requested playbooks)

Skills live under `.github/skills/<skill-name>/SKILL.md`.

How to invoke a skill in chat:

- Say something like: **“Use the `<skill-name>` skill to …”**
- Then provide the concrete goal and constraints (platform, target files, acceptance criteria).

#### Installed skills

General planning / navigation:

- `context-map` — Generate a map of relevant files for a task before making changes.
- `create-implementation-plan` — Create an implementation plan file for new features/refactors.
- `update-implementation-plan` — Update an existing implementation plan file.
- `refactor-plan` — Plan multi-file refactors with sequencing/rollback.
- `what-context-needed` — Ask what files Copilot needs before answering.

Quality & verification:

- `doublecheck` — Verification pipeline to reduce hallucinations.
- `webapp-testing` — Playwright-based UI testing workflow.

Security:

- `security-review` — Security-focused codebase scan.
- `secret-scanning` — Guidance for configuring/triaging secret scanning.
- `dependabot` — Dependabot configuration and update strategy guidance.

Database (Supabase/Postgres):

- `postgresql-code-review` — Postgres-specific SQL review.
- `postgresql-optimization` — Postgres-specific performance tuning.
- `sql-code-review` — Universal SQL review checklist (pairs well with Postgres-specific skill).
- `sql-optimization` — Universal SQL performance workflow.

Privacy/compliance:

- `gdpr-compliant` — Practical privacy-by-design checklist.

Release readiness:

- `apple-appstore-reviewer` — Static iOS App Store readiness audit for Flutter apps.

Security scanning (GitHub):

- `codeql` — Add/troubleshoot CodeQL scanning workflows and alerts.

### 4) Agents (specialized modes)

Agents live under `.github/agents/*.agent.md`.

In Copilot Chat, select an agent when you want a specialized output style:

- `adr-generator.agent.md` — Creates an Architectural Decision Record (ADR).
- `implementation-plan.agent.md` — Generates a structured implementation plan.

---

## Contributing new instructions/skills

- Prefer **narrow `applyTo` patterns** to avoid wasting context.
- Keep instructions high-signal and repo-specific.
- If you add env vars or config conventions, update the main `README.md` and `.env.example` (and never add secrets).

---

## Provenance

Several instruction/skill templates were inspired by the `github/awesome-copilot` repository:

- https://github.com/github/awesome-copilot
