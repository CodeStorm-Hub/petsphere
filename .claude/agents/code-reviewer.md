# Code Reviewer Agent for PetSphere

Specialized code review agent for PetSphere Flutter codebase, focusing on Riverpod patterns, architecture compliance, and Dart best practices.

## Trigger

Invoke this agent when you need a comprehensive code review before merging:

```bash
# Review current branch for architecture compliance
claude @code-reviewer "Review this branch for Riverpod patterns and null safety"

# Review specific files
claude @code-reviewer "Review lib/controllers/pet_controller.dart for state management"

# Review PR diff
claude @code-reviewer "Code review: ensure immutability and error handling in lib/repositories/"
```

## Review Checklist

The agent verifies:

### Architecture & Patterns ✅
- [ ] Feature uses the correct layer (model → repo → controller → view)
- [ ] Notifier extends `Notifier<State>`, not `StateNotifier`
- [ ] State is immutable with `copyWith()` implementation
- [ ] All data access flows through repositories
- [ ] Controllers don't bypass repositories
- [ ] Views use `ConsumerWidget` or `ConsumerStatefulWidget` where needed

### Riverpod & State Management ✅
- [ ] Providers are declared at file end
- [ ] `NotifierProvider` used for mutable state
- [ ] `StateProvider` used for simple scalars
- [ ] `FutureProvider` used only for single-value async (not long-running)
- [ ] `ref.watch()` for UI state subscription
- [ ] `ref.read()` for triggering actions
- [ ] Proper error handling in notifier methods
- [ ] Loading states set before/after async operations

### Null Safety & Type Safety ✅
- [ ] No `!` operator without justified non-null guarantees
- [ ] Use `?.` for safe optional access
- [ ] Optional parameters use `?` type annotations
- [ ] `late` used sparingly with clear initialization
- [ ] All types are explicit (no untyped `var` or `dynamic`)

### Model & Data Integrity ✅
- [ ] Models are immutable (all fields `final`)
- [ ] `fromJson()` parses snake_case from Supabase correctly
- [ ] `toJson()` converts back to snake_case for Supabase
- [ ] `copyWith()` creates new instances (not mutating)
- [ ] Enum handling is type-safe

### Repository Pattern ✅
- [ ] Async operations return typed futures (not `dynamic`)
- [ ] Error handling: exceptions propagate (not swallowed)
- [ ] Supabase queries use `.select()` with explicit columns
- [ ] RLS policies are considered in query design
- [ ] Image uploads specify bucket path correctly

### Code Quality ✅
- [ ] Methods under 20 lines (extract complex logic)
- [ ] No magic numbers (use named constants)
- [ ] Imports organized: dart, package, relative
- [ ] Snake_case for files, PascalCase for classes, camelCase for variables
- [ ] No `print()` (use `developer.log()` instead)
- [ ] Comments explain "why" not "what"
- [ ] No TODO comments in production code (document issues in Linear/GitHub)

### Error Handling ✅
- [ ] Try-catch at repository/controller layers
- [ ] Errors propagate to UI (state.error field)
- [ ] User-friendly error messages (no stack traces in UI)
- [ ] Network errors distinguished from validation errors

### Testing Readiness ✅
- [ ] Methods are testable (dependencies injectable or via Riverpod)
- [ ] State classes have test-friendly constructors
- [ ] No hardcoded dependencies or singletons (except repositories)
- [ ] No untestable async code in build methods

## Output

The agent provides:

1. **Pass/Fail Summary** — Architecture compliance status
2. **Issues Found** — Specific violations with line numbers
3. **Suggestions** — Refactoring recommendations
4. **Examples** — Corrected code snippets for violations
5. **Approval** — Merged/approved status with caveats

## Integration with CI/CD

For automated pre-merge reviews, use in GitHub Actions:

```yaml
# .github/workflows/code-review.yml
name: PetSphere Code Review

on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Claude Code Review
        run: |
          claude @code-reviewer "Review PR changes for architecture and patterns"
```

## Known Issues & Edge Cases

- **Large PRs**: Reviews top 20 files; request split reviews for >50 files
- **Generated Code**: Skips code generation artifacts (normally)
- **External Packages**: Doesn't review vendored code
- **Monorepos**: Specify path for review scope

## Tips

- Run before opening a PR for faster feedback
- Use for onboarding new team members (learn patterns)
- Run monthly on main to catch drift
- Pair with `/test-writer` skill for comprehensive coverage
