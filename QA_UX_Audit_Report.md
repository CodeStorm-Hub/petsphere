# PetSphere QA / UX Accessibility Audit

**Report ID:** PS-QA-2026-05-03  
**Auditor role:** QA Automation + UI/UX (autonomous tooling)  
**App package:** `com.example.pet_dating_app` (PetSphere debug build)  
**Incremental log:** This file is updated during the audit run; later phases may be extended after a confirmed login.

---

## 0. Environment & tooling reality check

| Item | Result |
|------|--------|
| **ADB devices** | Only `emulator-5554` was attached. **No wireless/physical device serial appeared** in `adb devices -l`. All steps below ran on this emulator unless you reconnect the wireless device. |
| **App install** | Initial state had **no installed package** for PetSphere on the emulator. A **debug APK** was built (`flutter build apk --debug`) and installed with `adb install -r`. |
| **Automation stack** | `uiautomator dump` + repo skill script `screen_mapper.py` (`.claude/skills/android-emulator-skill/scripts`). |
| **Credentials** | Sign-in was attempted with the stakeholder-supplied test account. **The password is not copied into this report.** Because the password was shared in chat, **rotate it if this workspace or logs could be shared.** |

### Flutter + UIAutomator caveat (critical)

Flutter renders to a canvas; the Android accessibility bridge maps a **semantics tree** into `EditText` / `Button` nodes. When dumps are empty or nearly empty, **do not guess coordinates**: enable semantics debugging or add `Semantics` (see [Flutter accessibility widgets](https://docs.flutter.dev/development/ui/widgets/accessibility)). Known gaps exist for `TextField` `content-desc` in some versions (e.g. [flutter#153495](https://github.com/flutter/flutter/issues/153495)).

---

## Phase 1 — Authentication & baseline

### Screen: **Login / welcome**

**Accessibility / semantics status**

- **Partially exposed:** Native nodes present (`android.widget.EditText` ×2, buttons with `content-desc`: `Sign In`, `Forgot Password?`, etc.).
- **Gaps identified:**
  - **Email `EditText`** surfaced the **typed email as plain `text` in the UIAutomator XML** (visible to dumps and hybrid automation). This is expected for non-obscured fields but is a **privacy consideration** for screen recording and shared logs.
  - **Password field** showed **replacement characters / mojibake** in the dump (obscured text pipeline), which breaks **reliable textual validation** of entry via XML alone.
  - `content-desc` on the two `EditText` nodes was **empty** in captured dumps; identification relied on order and bounds.

**Available actions identified (UIAutomator)**

- Enter email and password, **Sign In**, **Forgot Password?**, **Register**, **Google**, **Apple**, scrollable marketing copy (**Welcome Back**, **PetSphere** branding).

**Test cases executed**

- Launch: `am start -n com.example.pet_dating_app/.MainActivity`
- **Data:** Stakeholder email `afsanchowdhury25@gmail.com`; password supplied out-of-band (not logged here). Entry used `adb shell input text` plus `keyevent 77` for `@`.

**Issues / errors**

- **P1 — Home baseline not reached:** After **Sign In** taps (center of button bounds), the hierarchy **remained on the login screen** (`Welcome Back`, `Sign In` still present). Possible causes: wrong credentials for this Supabase project, network/auth error not surfaced in the automation capture, IME/focus so password never committed, or loading state not waited long enough.
- **P2 — Automation fragility:** Coordinate-based ADB typing is brittle for Flutter fields; **password obscuring** complicates XML verification.
- **P3 — Device mismatch:** Instructions assumed a **wireless physical device**; only an **emulator** was available in this session.

**Proposed fixes & best practices (with research)**

1. **Semantics for forms:** Wrap critical fields with explicit `Semantics` (`label`, `textField`, `obscured` for password) so TalkBack / automation trees are stable; align with [SemanticsProperties](https://docs.flutter.dev/flutter/semantics/SemanticsProperties-class.html).  
   - **Code change applied in-repo:** `lib/views/login_screen.dart` now wraps email/password `TextFormField`s in `Semantics` with labels **Email address** and **Password** (and `obscured: true` on the password semantics). Rebuild the APK to validate improved dumps.
2. **Preferred automated auth:** Use **`integration_test`** + `WidgetTester.enterText` and `Key('login_email_field')` / `Key('login_password_field')` (already present) instead of raw `input text` for real credentials ([Flutter integration testing](https://docs.flutter.dev/testing/integration-tests)).
3. **Material 3 / forms:** Keep **visible labels**, **clear validation**, and **error region** semantics; ensure loading states expose `Semantics` (e.g. announcing progress) per Material accessibility guidance.

**Feature improvements**

- Surface **inline auth failure messages** in a semantics-friendly region (live region) when Supabase rejects credentials.
- Consider **biometric / token** dev-only bypass for QA builds (guarded by flavor) to unblock full navigation audits without storing passwords in scripts.

---

### Screen: **Home (Atelier feed)** — *baseline not captured*

**Status:** **Blocked** pending successful authentication. No `Atelier` / bottom-nav semantics (`Home`, `Discover`, …) appeared in post-login dumps in this session.

**Planned sequence when unblocked (Phase 2 template)**

For **each** screen, the following will be executed:

1. Scroll to bottom (lazy load).  
2. Dump UI tree; list clickable elements.  
3. Execute each action with pet-care realistic data.  
4. Check errors, loaders, overflows.  
5. Navigate back without loops.

---

## Phase 2 — Screen-by-screen

| Screen | Status |
|--------|--------|
| Home / feed | **Reached** (emulator). UI shows **Atelier** title, **Search** AppBar actions, **Retry** on feed error. UIAutomator dump exposed `content-desc="Home"` / `Discover` on bottom nav. DB error surfaced in semantics: Postgrest **infinite recursion** on `pets` RLS (42P17). |
| Discover | Bottom tab present; deep dive pending |
| Pet care hub | Not exercised |
| Marketplace | Not exercised |
| Profile | Not exercised |
| Search / notifications / messages from home AppBar | Semantics present (`Search`, etc.) |

**Flutter Driver (Phase 1 journey):** `flutter drive` test passes when the test body runs inside **`driver.runUnsynchronized`**. Default frame sync waits until **no transient callbacks**; splash/home **`CircularProgressIndicator`** keeps callbacks active, so `waitFor` / `tap` never complete. Shell is asserted with **`find.text('Atelier')`** and **`find.byTooltip('Search')`**; bottom **Discover** tab uses **`find.byValueKey('bottom_nav_1')`** (`main_layout.dart`).

**Note:** Bottom nav items now have stable **`ValueKey('bottom_nav_$index')`** plus **`bottom_nav_pet_care`** for the center FAB.

---

## Phase 3 — Consolidated recommendations

1. **Reconnect the physical wireless device** and re-run `adb devices`; update this report with the real serial.  
2. **Rebuild & reinstall** after the login `Semantics` change; re-dump login XML and confirm `content-desc` / node labels for both fields.  
3. **Confirm Supabase user** exists for the test email in the **same project** as the app’s `supabaseInitUrl` / anon key (debug vs release defines).  
4. For **full Phase 2**, either: fix auth for the test account, or use a **QA-only service role / test user seed** (policy-compliant) plus `integration_test`.  
5. Optional dev aid: temporary **`MaterialApp.router(..., showSemanticsDebugger: true)`** in debug builds to visualize semantics during audits (remove before store).

---

## References (external)

- [Flutter — Accessibility widgets](https://docs.flutter.dev/development/ui/widgets/accessibility)  
- [Flutter API — SemanticsProperties](https://docs.flutter.dev/flutter/semantics/SemanticsProperties-class.html)  
- [GitHub — TextField / UIAutomator content description discussion](https://github.com/flutter/flutter/issues/153495)  
- [Flutter — Integration tests](https://docs.flutter.dev/testing/integration-tests)

---

## Changelog

| Time (UTC) | Update |
|------------|--------|
| 2026-05-03 | Initial environment check; APK install; login screen mapped; sign-in blocked at home; login Semantics patch landed in `login_screen.dart`; wireless device not present in `adb devices`. |
| 2026-05-03 | Driver test green: `runUnsynchronized` + `Atelier`/`Search` finders + nav `ValueKey`s; `auth_controller` cold-start profile fetch timeout (15s) to avoid stuck splash if `profiles` hangs; QA: fix `pets` RLS recursion. |
