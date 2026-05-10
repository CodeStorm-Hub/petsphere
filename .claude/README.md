# Claude Code Configuration for PetFolio

This directory contains tailored automation, skills, and settings for PetFolio Flutter development.

## 📋 Contents

### Configuration
- **`settings.json`** — Project-wide settings including hooks, permissions, and MCP server configuration

### Skills (User-Invocable)

#### 1. `/flutter-new-component`
Scaffold new reusable Flutter components following PetFolio patterns.

```bash
/flutter-new-component PetCard "Displays a pet profile card"
/flutter-new-component HealthMetricGraph "Shows health trend chart" --stateful
/flutter-new-component CareBadgeList "Lists earned care badges" --consumer
```

**Output**: Creates `lib/views/components/{component_name}.dart` with proper typing, theming, and patterns.

---

#### 2. `/test-writer`
Generate unit tests for Notifiers, repositories, and utilities following arrange-act-assert pattern.

```bash
/test-writer lib/controllers/pet_controller.dart
/test-writer lib/repositories/health_repository.dart --coverage
```

**Output**: Creates test files in `test/` mirroring `lib/` structure with mocks and test cases.

---

#### 3. `/migration-helper`
Scaffold complete feature layers (model + repository + controller) in one command.

```bash
/migration-helper PetNutrition "Track pet nutrition and dietary info" --table-name=pet_nutrition
/migration-helper ActivityLog "Log pet daily activities" --table-name=activity_logs
```

**Output**: 
- `lib/models/{feature_name}_model.dart`
- `lib/repositories/{feature_name}_repository.dart`
- `lib/controllers/{feature_name}_controller.dart`

All three files follow PetFolio architecture patterns and are production-ready.

---

### Agents (Specialized Reviewers)

#### Code Reviewer (`@code-reviewer`)
Comprehensive code review agent focused on Riverpod patterns, architecture compliance, and Dart best practices.

```bash
# Review current branch
claude @code-reviewer "Review this branch for Riverpod patterns and null safety"

# Review specific files
claude @code-reviewer "Review lib/controllers/ for state management"

# Pre-PR review
claude @code-reviewer "Code review before merge"
```

**Checks**:
- Architecture layer compliance
- Riverpod patterns (Notifier, State, providers)
- Null safety and type safety
- Model immutability
- Repository pattern compliance
- Code quality and style
- Error handling
- Testing readiness

---

## ⚡ Hooks (Automatic)

The following hooks run automatically on file edits:

### Auto-Format & Lint
Runs `dart format` and `flutter analyze` after each edit.
- Keeps code style consistent
- Catches linting issues early
- Runs automatically, no user action needed

### Protected Files
Prevents accidental edits to sensitive files:
- `pubspec.lock` (version lock file)
- `.env*` (secrets and config)
- `lib/utils/supabase_config.dart` (credentials)
- `android/local.properties`, `ios/local.properties`

---

## 🔌 MCP Servers (Recommended)

Two MCP servers are configured in `settings.json` for enhanced capabilities:

### 1. **Supabase MCP**
Direct access to your PostgreSQL database.

**Usage**:
- Inspect table schemas
- Debug RLS policies
- Test SQL queries
- Monitor migration status

---

### 2. **context7 MCP**
Real-time documentation lookup for Flutter/Dart/Riverpod.

**Usage**:
- Look up Flutter API docs while coding
- Check Riverpod pattern documentation
- Search Dart language features
- Find Material Design guidelines

---

## 🚀 Quick Start

### 1. Enable Hooks
Hooks are configured in `settings.json` and should activate automatically. Test with:
```bash
# Edit any Dart file and verify `dart format` runs
echo "void main(){}" > lib/test.dart
# Should be auto-formatted to proper style
```

### 2. Try a Skill
Generate your first component:
```bash
/flutter-new-component TestCard "A test component"
```

Look for the created file in `lib/views/components/test_card.dart`.

### 3. Run a Full Feature Migration
Create a complete feature layer:
```bash
/migration-helper TestFeature "A test feature" --table-name=test_features
```

Check created files:
- `lib/models/test_feature_model.dart`
- `lib/repositories/test_feature_repository.dart`
- `lib/controllers/test_feature_controller.dart`

### 4. Code Review Before Merge
Before pushing to GitHub:
```bash
claude @code-reviewer "Review my feature branch for architecture compliance"
```

---

## 📚 Recommended Workflow

### When Adding a New Feature

1. **Scaffold with `/migration-helper`**
   ```bash
   /migration-helper PetNutrition "Track nutrition" --table-name=pet_nutrition
   ```

2. **Generate Tests with `/test-writer`**
   ```bash
   /test-writer lib/controllers/pet_nutrition_controller.dart
   ```

3. **Create UI Components with `/flutter-new-component`**
   ```bash
   /flutter-new-component NutritionCard "Shows nutrition info"
   /flutter-new-component NutritionForm "Edit nutrition record" --stateful
   ```

4. **Review Before Merge**
   ```bash
   claude @code-reviewer "Code review for nutrition feature"
   ```

5. **Hooks run automatically** — no manual linting needed

---

## 🔧 Customizing

### Add More Hooks
Edit `settings.json` hooks section to add auto-format for other languages or add validation checks.

Example: Auto-run tests on Dart file edits:
```json
{
  "trigger": "PostToolUse",
  "tool": "Edit",
  "command": "flutter test --help"
}
```

### Modify Protected Files
Edit the `preToolUse` section to add/remove protected paths.

---

## 📖 File Organization

```
.claude/
├── settings.json                              # Project-wide config
├── README.md                                  # This file
├── skills/
│   ├── flutter-new-component/SKILL.md
│   ├── test-writer/SKILL.md
│   └── migration-helper/SKILL.md
└── agents/
    └── code-reviewer.md
```

---

## 🆘 Troubleshooting

### Hooks Not Running
- Verify `settings.json` is valid JSON (no trailing commas)
- Check file paths are correct relative to project root
- Reload Claude Code: File → Reload

### Skills Not Appearing
- Ensure `SKILL.md` files are in `.claude/skills/{name}/SKILL.md`
- Reload Claude Code
- Check skill name in frontmatter matches directory name

### Code Review Agent Issues
- Ensure sufficient tokens available (large reviews may timeout)
- Split very large PRs into multiple reviews
- Check git repo is initialized (agent needs git context)

---

## 📝 Notes

- Skills can be customized further by editing their `.md` files
- All generated code is production-ready; update with your custom logic
- Tests generated have TODO comments for custom assertions
- Settings are project-specific; team members should use same `.claude/` directory

---

**Last Updated**: 2026-05-05  
**Version**: 1.0  
**Maintained by**: Claude Code Automation System
