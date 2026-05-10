# PetSphere Database - Quick Reference Guide

**Last Updated**: 2026-05-09  
**Database**: petsphere (PostgreSQL 17)  
**Tables**: 30 | **Columns**: ~210 | **ForeignKeys**: 75+

---

## 🚀 Quick Stats

```
✅ RLS Enabled:       29/30 tables (97%)
✅ Primary Entities:  2 (pets, auth.users)
✅ JSONB Fields:      7 (flexible data)
✅ Array Fields:      15+ (multi-values)
✅ Temporal Fields:   All tables tracked
✅ Status:            ACTIVE_HEALTHY
```

---

## 📊 Table Directory (Alphabetical)

| # | Table | Rows | Columns | Domain | PK |
|---|-------|------|---------|--------|-----|
| 1 | care_badge_definitions | 6 | 5 | Gamification | slug |
| 2 | chat_threads | 0 | 5 | Messaging | id |
| 3 | comments | 0 | 5 | Social | id |
| 4 | follows | 0 | 5 | Social | id |
| 5 | match_requests | 0 | 5 | Matching | id |
| 6 | messages | 0 | 8 | Messaging | id |
| 7 | notifications | 0 | 7 | User | id |
| 8 | orders | 0 | 6 | Marketplace | id |
| 9 | pet_activities_logs | 0 | 8 | Care | id |
| 10 | pet_allergies | 0 | 7 | Health | id |
| 11 | pet_care_badge_unlocks | 0 | 4 | Gamification | id |
| 12 | pet_care_gamification | 0 | 12 | Gamification | pet_id |
| 13 | pet_care_logs | 0 | 22 | Care | id |
| 14 | pet_care_onboarding | 0 | 4 | Gamification | pet_id |
| 15 | pet_dental_logs | 0 | 6 | Health | id |
| 16 | pet_medication_doses | 0 | 6 | Health | id |
| 17 | pet_medications | 0 | 10 | Health | id |
| 18 | pet_parasite_prevention | 0 | 8 | Health | id |
| 19 | pet_symptoms | 0 | 7 | Health | id |
| 20 | pet_vaccinations | 0 | 8 | Health | id |
| 21 | pet_vet_appointments | 0 | 7 | Health | id |
| 22 | pet_weight_logs | 0 | 5 | Care | id |
| 23 | pets | 0 | 21 | Core | id |
| 24 | post_likes | 0 | 3 | Social | (post_id, pet_id) |
| 25 | posts | 0 | 8 | Social | id |
| 26 | products | 0 | 13 | Marketplace | id |
| 27 | profiles | 0 | 8 | User | id |
| 28 | stories | 0 | 8 | Social | id |
| 29 | user_fcm_tokens | 0 | 4 | User | (user_id, fcm_token) |
| 30 | waitlist | 0 | 5 | Admin | id |

---

## 🔗 Relationship Map

### PETS Hub (26 connections)
```
pets ←→ 26 tables:
  📱 Social:     posts, post_likes, comments, stories, follows
  💬 Messaging:  match_requests, chat_threads, messages
  ❤️ Health:     8 health-related tables
  🎮 Care:       3 care-tracking tables
  🏆 Gamification: 4 badge/streak tables
  ↪️ Owner:      auth.users (user_id)
```

### AUTH.USERS Hub (10+ connections)
```
auth.users ←→ 10+ tables:
  👤 Identity:    profiles, user_fcm_tokens
  📦 Business:    orders (buyer), products (vendor)
  🔔 Engagement:  notifications, follows
  📋 Logging:     health records, activity logs
  ➕ Other:       pets (ownership), waitlist
```

---

## 📈 Cardinality Overview

```
One-to-One (1:1)
├── profiles ← auth.users
├── pet_care_gamification ← pets
└── pet_care_onboarding ← pets

One-to-Many (1:N)
├── pets → posts, stories, comments
├── posts → post_likes, comments
├── chat_threads → messages
├── pet_medications → pet_medication_doses
└── ... (50+ more)

Many-to-Many (M:N)
├── posts ↔ pets (via post_likes)
├── posts ↔ pets (via comments)
├── pets ↔ pets (via match_requests)
├── pets ↔ pets (via chat_threads)
├── users ↔ users/pets (via follows)
└── pets ↔ badges (via pet_care_badge_unlocks)
```

---

## 🔐 Security & Access

### RLS Status
- ✅ **29/30** tables have RLS enabled
- ❌ **auth.users** managed by Supabase (built-in)

### Data Sensitivity
```
🔴 CRITICAL:
  - auth.users (passwords, auth tokens)
  - notifications (personal alerts)
  - messages (private conversations)
  - health records (allergies, symptoms, meds)
  - orders (payment data)

🟡 HIGH:
  - pet_care_logs (activity data)
  - follows (relationship data)

🟢 MEDIUM:
  - posts, stories, comments (semi-public)
  - products (vendor listings)
```

---

## ⚡ Query Optimization Tips

### For Feed/Timeline
```sql
-- DON'T: N+1 queries
SELECT * FROM posts WHERE pet_id = ?;
SELECT * FROM post_likes WHERE post_id = ?;
SELECT * FROM comments WHERE post_id = ?;

-- DO: Single aggregated query
SELECT p.*, 
  COUNT(DISTINCT pl.pet_id) as like_count,
  COUNT(DISTINCT c.id) as comment_count
FROM posts p
LEFT JOIN post_likes pl ON p.id = pl.post_id
LEFT JOIN comments c ON p.id = c.post_id
WHERE p.pet_id = ?
GROUP BY p.id;
```

### For Health Dashboard
```sql
-- DON'T: 8 separate queries for 8 health tables
-- DO: Use CTEs or view aggregation
WITH health_summary AS (
  SELECT pet_id, 'medication' as type, COUNT(*) as count
  FROM pet_medications WHERE pet_id = ? AND is_active
  UNION ALL
  ...
)
SELECT * FROM health_summary;
```

### For Messaging
```sql
-- Index on thread_id + created_at
CREATE INDEX idx_messages_thread_id_created_at 
ON messages(thread_id, created_at DESC);

-- Unread count aggregation
SELECT thread_id, COUNT(*) as unread
FROM messages
WHERE is_read = false AND sender_pet_id != ?
GROUP BY thread_id;
```

---

## 🛠️ Common Operations

### Create Pet
```sql
INSERT INTO pets (user_id, name, breed, animal_type)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- Cascade creates:
-- - pet_care_gamification (auto)
-- - pet_care_onboarding (auto)
```

### Log Daily Care
```sql
INSERT INTO pet_care_logs (pet_id, log_date, breakfast_fed, dinner_fed, ...)
VALUES ($1, CURRENT_DATE, true, false, ...)
ON CONFLICT (pet_id, log_date) DO UPDATE SET ...;
```

### Create Post
```sql
INSERT INTO posts (pet_id, media_url, caption, location, tagged_pet_ids)
VALUES ($1, $2, $3, $4, $5::uuid[])
RETURNING *;
```

### Send Message
```sql
INSERT INTO messages (thread_id, sender_pet_id, text, message_type)
VALUES ($1, $2, $3, 'text')
RETURNING *;

UPDATE chat_threads SET updated_at = NOW() WHERE id = $1;
```

### Track Health
```sql
INSERT INTO pet_symptoms (pet_id, user_id, symptom_name, severity, logged_at)
VALUES ($1, $2, $3, $4, NOW());

INSERT INTO pet_medications (pet_id, user_id, name, dosage, frequency)
VALUES ($1, $2, $3, $4, $5);
```

---

## 📊 Data Volume Estimates

| Stage | Pets | Posts | Messages | Storage |
|-------|------|-------|----------|---------|
| MVP (3mo) | 1K | 10K | 50K | 100 MB |
| Growth (1yr) | 100K | 500K | 5M | 5-10 GB |
| Scale (2yr+) | 1M+ | 5M+ | 50M+ | 50-100 GB |

---

## 🚀 Performance Benchmarks (Target)

```
✅ GET user's pets:           < 10ms
✅ GET pet's feed:            < 50ms (with pagination)
✅ GET health dashboard:      < 100ms (aggregating 8 tables)
✅ GET chat messages:         < 30ms (paginated)
✅ POST new post:            < 100ms (with image upload)
✅ UPDATE care log:          < 50ms
```

---

## 🔍 Debugging Common Issues

### "Unknown column X"
- Check table name in `DATABASE_SCHEMA.md`
- Verify column spelling (snake_case)

### "Foreign key violation"
- Parent record must exist first
- Check FK relationships in ERD_DIAGRAM.md

### "RLS policy denies access"
- Verify `auth.uid()` is user_id in table
- Check RLS policy in CLAUDE.md or database

### "Slow queries on health dashboard"
- Add index: `CREATE INDEX idx_pet_health ON pet_medications(pet_id, is_active);`
- Use CTE to aggregate across 8 tables

### "Messages not appearing in chat"
- Verify `chat_threads` with both pet IDs exist
- Check message `is_read` flag
- Ensure `thread_id` FK matches

---

## 📚 Documentation Map

| File | Purpose | Use When |
|------|---------|----------|
| **DATABASE_SCHEMA.md** | Complete table reference | Need column definitions |
| **ERD_DIAGRAM.md** | Visual relationships | Need ER diagram |
| **DATABASE_SCHEMA_EXPORT.json** | Machine-readable schema | Programmatic access |
| **DATABASE_ANALYSIS_SUMMARY.md** | Strategic insights | Planning improvements |
| **QUICK_REFERENCE.md** | This file | Need quick lookup |
| **CLAUDE.md** | Dev guide in repo | Building features |

---

## 🎯 Key Takeaways

1. **Pet-Centric**: All data flows through `pets` table (26 dependents)
2. **User-Owned**: All pets owned by `auth.users` (authorization layer)
3. **Multi-Domain**: Social + Health + Care + Marketplace all integrated
4. **Scalable**: Designed to grow from MVP to enterprise
5. **Secure**: RLS enabled for data isolation
6. **Flexible**: JSONB for semi-structured data (tasks, badges, etc.)
7. **Tracked**: Timestamps on everything for audit trails

---

## 💡 Pro Tips

- Use `.select()` with specific columns to reduce payload
- Index on `(pet_id, created_at DESC)` for time-series queries
- Cache `care_badge_definitions` (only 6 rows, never changes)
- Use CTEs for complex health aggregations
- Materialize views for analytics (engagement, daily stats)
- Archive `pet_care_logs` after 1 year for cold storage

---

**Last Updated**: 2026-05-09  
**Database**: petsphere (PostgreSQL 17.6.1)  
**Region**: ap-southeast-1  
**Maintainer**: PetSphere Development Team
