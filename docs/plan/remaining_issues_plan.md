# PetSphere – Remaining Issues & Implementation Plan

> **Generated:** May 7, 2026 | Based on GitHub issues + docs/codebase cross-check

## ✅ Already Closed (18 issues)

| # | Title | Epic |
|---|-------|------|
| #23 | Cart persistence (SharedPreferences) | #57 |
| #24 | FCM deep-link navigation | #59 |
| #25 | Appointment sync (HealthController → PetCare) | #54 |
| #26 | Server-side stock validation | #57 |
| #27 | Feed repo compile error | #58 |
| #28 | Auth: profile upsert fatal | #58 |
| #30 | Testing foundation | #58 |
| #31 | Supabase migrations workflow | #58 |
| #32 | Stripe payment integration | #57 |
| #35 | Offline support baseline | #55 |
| #38 | Route hardening | #58 |
| #40 | Stories expiry filter | #60 |
| #42 | Comment author pet details | #60 |
| #54 | EPIC: Care & Health Improvements | — |
| #57 | EPIC: Marketplace Reliability | — |
| #58 | EPIC: Foundation & Release Blockers | — |
| #59 | EPIC: Notifications & FCM | — |

---

## 🔴 Open Issues — 29 remaining

### Group A: Close-ready (implemented but not closed)
These were implemented in the codebase but GitHub issues left open.

| # | Title | Action |
|---|-------|--------|
| #29 | Follower count N+1 → batch `fetchPetFollowerCounts` done | Close |
| #39 | Care cache flicker → payload dedup done | Close |
| #41 | Realtime channel cleanup → feed + chat lifecycle done | Close |
| #48 | Supabase debug fallback config → `SUPABASE_ALLOW_EMBEDDED_DEBUG_FALLBACK` done | Close |

### Group B: Health sub-issues (P1)

| # | Title | Status |
|---|-------|--------|
| #43 | Appointment overdue alerts in UI state | ❌ Not implemented |
| #44 | Auto-generate medication doses (30-day schedule) | ❌ Not implemented |
| #47 | Vaccination recurrence via reference schedule table | ❌ Not implemented |

### Group C: Pet management (P2)

| # | Title | Status |
|---|-------|--------|
| #45 | Pet photo delete → storage cleanup | ❌ Not implemented |
| #46 | Breed autocomplete + validation | ❌ Not implemented |

### Group D: All stub screens (Epic #56 — P1-P2)

| # | Screen | Status |
|---|--------|--------|
| #33 | Vet Booking (reuse `pet_vet_appointments` table) | ❌ Mock only |
| #34 | Lost & Found (new tables + workflow) | ❌ Mock only |
| #36 | Community Groups (groups + membership) | ❌ Mock only |
| #37 | Adoption Center (listings + applications) | ❌ Mock only |
| #49 | Meta: complete all remaining mock screens | ❌ Open |
| #50 | Pet Training (programs + progress per pet) | ❌ Mock only |
| #51 | Pet Sitter Dashboard (profiles + booking) | ❌ Mock only |
| #52 | Pet Insurance Hub (claims + status) | ❌ Mock only |
| #62 | Pet Friendly Places (data-driven list/map) | ❌ Mock only |
| #63 | Nutrition Planner (personalized + persistent) | ❌ Mock only |
| #64 | Knowledge Base (articles + search) | ❌ Mock only |
| #65 | Gear Reviews (CRUD + ratings) | ❌ Mock only |
| #66 | Breed Identifier (real ML/API, not fake scan) | ❌ Fake scan |
| #67 | Pet Memorial (archival + entries) | ❌ Mock only |
| #68 | Pet Events Discovery (events + RSVP) | ❌ Mock only |

### Open Epics (need sub-issues done first)

| # | Title | Blocking Sub-issues |
|---|-------|---------------------|
| #55 | EPIC: Offline, Performance & Query Efficiency | #29 done → close |
| #60 | EPIC: Social Feed, Stories & Realtime Quality | #40,#42 done; #41 close |
| #61 | EPIC: Security & Config Hygiene | #48 close |
| #69 | EPIC: Pet Profile Quality | #45, #46 |
| #56 | EPIC: Complete Stub Screens | All #33–68 sub-issues |

---

## 📋 Sequential Implementation Order

```
Phase 1 (immediate): Close already-done issues #29, #39, #41, #48
Phase 2: Health issues #43, #44, #47
Phase 3: Pet mgmt #45, #46
Phase 4 (stub screens):
  4a. #33 Vet Booking
  4b. #34 Lost & Found
  4c. #36 Community Groups
  4d. #37 Adoption Center
  4e. #50 Pet Training
  4f. #52 Pet Insurance Hub
  4g. #51 Pet Sitter Dashboard
  4h. #63 Nutrition Planner
  4i. #62 Pet Friendly Places
  4j. #64 Knowledge Base
  4k. #65 Gear Reviews
  4l. #67 Pet Memorial
  4m. #68 Pet Events Discovery
  4n. #66 Breed Identifier (API-based)
Phase 5: Close epics #55, #60, #61, #69, #56
```
