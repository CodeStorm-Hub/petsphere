---
description: "Keep Copilot changes safe and reviewable: small diffs, confirm assumptions, and avoid wide refactors."
applyTo: "**/*"
---

# Taming Copilot (keep changes safe)

This repo already has strong guidance in `.github/copilot-instructions.md`. Use this file as a lightweight reinforcement when work touches many files.

## Rules

- Make the **smallest** change that solves the problem.
- Avoid drive-by refactors, reformatting, and mass renames.
- If requirements are ambiguous, ask 1–3 targeted questions.
- Prefer adding tests or quick validation steps over “looks right”.
- Keep secrets out of code and logs.

## Source

Inspired by the awesome-copilot instruction:
https://github.com/github/awesome-copilot/blob/main/instructions/taming-copilot.instructions.md
