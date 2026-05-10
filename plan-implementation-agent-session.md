Reverting all name changes back to PetFolio now.

Good. Git has restored those source files. Now also revert `pubspec.yaml` name change back to `pet_dating_app` and restore the original test files:

Now revert the test files that were changed by sed:

Now verify everything is clean — check that no PetSphere references remain in dart files:

Good — all branding is clean. The `.gitignore` and `analysis_options.yaml` improvements are still in place (they weren't reverted). Now re-add the new packages to `pubspec.yaml` with the correct package name kept as `pet_dating_app`:

Now run analyze to confirm source code is clean:

Zero errors — only 174 info/warnings (pre-existing). Now update the todo and progress file, then proceed to Step 1.2 (database security):

Now Step 1.2 — database security fixes. I'll apply these via the Supabase MCP:

Project ID is `foubokcqaxyqgjhtgzsx`. Now applying security fixes. First, let me load the migration tool:

Applying security migration — missing RLS policies for 5 tables:

The parameter name is `pet_uuid`. Need to drop and recreate with correct name:

Need to get the dependent policy first, then drop cascade and recreate both:

Got the policy. Now drop cascade, recreate function as SECURITY INVOKER, and recreate the policy with optimized `(SELECT auth.uid())`:

Now optimize all other RLS policies that use `auth.uid()` without `SELECT`:

Now applying the bulk `(SELECT auth.uid())` optimization across all remaining policies in one migration:

All 3 security migrations applied. Now Step 1.3 — adding all 28 missing foreign key indexes:

`CONCURRENTLY` can't run in a transaction. Using plain `CREATE INDEX IF NOT EXISTS` instead:

Let me check actual column names for the failing tables:

Now let me update the progress tracker and move to Step 2.1.

Now moving to Step 2.1: feature-first architecture restructure. Let me assess the current layout.

Let me scope Step 2.1 properly — I'll check what files import the key infrastructure files before moving them.

Good — the scope is manageable. I'll move 5 infrastructure files and update ~41 import statements across ~35 files. Let me start by reading each file to move.

Now I have the full picture. I'll create the new directory structure, move the infrastructure files, and update all imports with package: paths. Starting with directory creation:

Now move the infrastructure files. For the ones with no local imports (supabase_config, connectivity_service, app_theme), I can just copy them directly:

Now update internal imports in the two files that reference relative local paths — push_notification_service.dart and router.dart:

Now run a global PowerShell regex replacement to update all other files that import the moved files:

Still 14 files — let me check what patterns remain:

I see — the offline repos still have the old path (under `pet_dating_app/utils/`). Let me fix those:

Those are already correct package: imports. Let me do a proper check for only OLD relative or wrong-path imports:

All old paths are clean. Now verify the app compiles:

One test file still uses the old import path. Let me fix it:

Zero errors. Now also check if the `lib/theme/` directory still exists (should be removed since it's empty):

Now create `lib/app/petfolio_app.dart` to extract the main app widget from `main.dart`, completing the `lib/app/` layer. First let me read main.dart:

Now I'll extract the app widget into `lib/app/petfolio_app.dart` and slim down `main.dart`:

Now slim down `main.dart` to only the bootstrap/initialization code:

Now remove the extracted classes from `main.dart` (keeping only `main()`):

Zero errors. Now update the progress tracker and move to Step 2.2:

Now Step 2.2 — split the 3 god controllers. Let me read all three to understand their size and what to split:

Let me check what files import each controller to understand the update scope:

I'll tackle the splits one at a time. Starting with `match_controller.dart` since it has the cleanest separation:

Let me check what each importer actually uses from match_controller:

The match_controller views are too deeply coupled to split safely without significant view changes. I'll do the most impactful, lowest-risk splits:
1. **health_controller.dart**: extract `medication_dose_controller.dart`
2. **pet_care_controller.dart**: extract `gamification_controller.dart`
3. **match_controller.dart**: extract just the `DiscoveryPetIdNotifier` into its own provider file and do cosmetic organization

Let me read health_controller.dart first:

Let me read pet_care_controller.dart's gamification section to plan the extract:

Now I'll create the `gamification_controller.dart` split. The gamification concern (`unlocks`, `gamification`, badge providers) is self-contained and several views only need it:

Let me check what the views use from gamification state:

Now I'll create `gamification_controller.dart` and trim `pet_care_controller.dart`:

Now update `pet_care_controller.dart` — remove gamification fields from state, remove `_syncCareRewards`, remove the badge providers, and delegate to `gamificationProvider`: