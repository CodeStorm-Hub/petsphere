# PetSphere Database Analysis Summary

**Generated**: 2026-05-09  
**Database**: petsphere (PostgreSQL 17.6.1)  
**Region**: ap-southeast-1  
**Status**: ACTIVE_HEALTHY ✅

---

## Executive Summary

PetSphere is a **comprehensive pet-centric social and wellness platform** with a well-structured database of **30 tables** organized across 8 functional domains. The database is **pet-centric**, with the `pets` table as the primary hub (26 dependent relationships), complemented by user authentication (`auth.users` with 10+ dependent tables).

### Key Highlights
- ✅ **Mature Architecture**: 75+ foreign keys with clear relationships
- ✅ **Data Protection**: RLS (Row-Level Security) enabled on 29/30 tables
- ✅ **Flexible Storage**: 7 JSONB fields for semi-structured data
- ✅ **Scalable Design**: Supports growth from small to enterprise scale
- ✅ **Full Feature Set**: Social, health, care, messaging, marketplace all covered

---

## Database Overview

### Scope & Scale

| Metric | Value |
|--------|-------|
| **Total Tables** | 30 |
| **Total Columns** | ~210 |
| **Foreign Keys** | 75+ |
| **Primary Entities** | 2 (pets, auth.users) |
| **RLS Enabled** | 29/30 (97%) |
| **JSONB Fields** | 7 |
| **Array Fields** | 15+ |
| **Rows (Estimated)** | 0 (new database) |

### Domain Distribution

| Domain | Tables | Purpose |
|--------|--------|---------|
| **User & Auth** | 2 | Authentication, profiles, tokens |
| **Core Pets** | 1 | Pet profiles (hub entity) |
| **Social Features** | 5 | Posts, stories, comments, likes, follows |
| **Matching & Messaging** | 4 | Match requests, chat, messages, notifications |
| **Health & Wellness** | 8 | Symptoms, meds, allergies, vaccinations, vet care |
| **Care Tracking** | 3 | Daily logs, activity, weight |
| **Gamification** | 4 | Badges, points, streaks, onboarding |
| **Marketplace** | 2 | Products, orders |
| **Administrative** | 1 | Waitlist |
| **TOTAL** | **30** | |

---

## Architecture Insights

### 1. Pet-Centric Hub Pattern ⭐

The `pets` table is the **central hub** with 26 dependent tables:

```
PETS (Hub)
├── Social (5): posts, stories, comments, post_likes, follows
├── Messaging (3): match_requests, chat_threads, messages
├── Health (8): symptoms, meds, allergies, dental, parasite, vaccines, vet, activity
├── Care (3): care_logs, activity_logs, weight_logs
├── Gamification (4): gamification, badge_unlocks, badges (via reference), onboarding
└── Relationships (1): follows (as followed_pet_id)
```

**Why this matters**: Queries naturally flow through `pets`, making it the fastest path to user data, activity feeds, health records, and care tracking.

### 2. User-Centric Authority Pattern ⭐

The `auth.users` table (Supabase Auth) governs:

```
AUTH.USERS (Authority)
├── Ownership: pets (owner via user_id)
├── Profile: profiles (1-to-1)
├── Business: orders (buyer), products (vendor)
├── Engagement: follows, notifications
├── Health Logging: user_id on symptom, med, allergy records
├── Tokens: user_fcm_tokens
└── Waitlist: waitlist entries
```

**Why this matters**: All data ultimately traces to an authenticated user, enabling RLS policies and privacy controls.

### 3. Flexible Relationship Patterns

#### Bidirectional (Pet-to-Pet)
- **match_requests**: sender_pet_id ↔ receiver_pet_id (dating)
- **chat_threads**: pet_id_1 ↔ pet_id_2 (conversations)

#### Many-to-Many (via junction tables)
- **post_likes**: posts ↔ pets
- **comments**: posts ↔ pets
- **follows**: users ↔ (users or pets)
- **pet_care_badge_unlocks**: pets ↔ badges

#### One-to-One (tracking)
- **pet_care_gamification**: 1 per pet (stats)
- **pet_care_onboarding**: 1 per pet (setup state)
- **profiles**: 1 per user (biographical)

---

## Feature Coverage Matrix

### Social Features
| Feature | Tables | Status |
|---------|--------|--------|
| Posts | posts, post_likes, comments | ✅ Complete |
| Stories | stories | ✅ Complete (24h TTL) |
| Following | follows | ✅ Complete (flexible model) |
| Matching | match_requests | ✅ Complete |
| Messaging | chat_threads, messages | ✅ Complete |
| Notifications | notifications | ✅ Complete |

### Health & Wellness
| Feature | Tables | Status |
|---------|--------|--------|
| Symptoms | pet_symptoms | ✅ Logged |
| Medications | pet_medications, pet_medication_doses | ✅ Tracked |
| Allergies | pet_allergies | ✅ Tracked |
| Vaccinations | pet_vaccinations | ✅ Scheduled/Completed |
| Parasite Prevention | pet_parasite_prevention | ✅ Logged |
| Dental Care | pet_dental_logs | ✅ Logged |
| Vet Appointments | pet_vet_appointments | ✅ Scheduled |

### Care Tracking
| Feature | Tables | Status |
|---------|--------|--------|
| Daily Feeding/Water | pet_care_logs | ✅ Rich (meals, goals, mood) |
| Exercise | pet_activity_logs | ✅ Logged |
| Weight | pet_weight_logs | ✅ Tracked |

### Gamification
| Feature | Tables | Status |
|---------|--------|--------|
| Streaks & Points | pet_care_gamification | ✅ Tracked |
| Badges (6 types) | care_badge_definitions, pet_care_badge_unlocks | ✅ Defined |
| Health Score | pet_care_gamification.health_score | ✅ Calculated |
| Onboarding | pet_care_onboarding | ✅ Completion tracking |

### Marketplace
| Feature | Tables | Status |
|---------|--------|--------|
| Product Listing | products | ✅ Complete |
| Shopping Cart | orders | ✅ Complete |
| Vendor Management | products (vendor_id) | ✅ Multi-vendor |

---

## Data Relationships

### Most Connected Tables (by foreign key count)

| Table | Incoming FKs | Outgoing FKs | Total | Role |
|-------|-------------|--------------|-------|------|
| **pets** | 26 | 1 | 27 | Hub |
| **auth.users** | 10+ | 0 | 10+ | Authority |
| **posts** | 2 | 1 | 3 | Core Social |
| **chat_threads** | 1 | 2 | 3 | Messaging |
| **pet_medications** | 2 | 1 | 3 | Health |

### Critical Paths (for common queries)

```
GET user's pets:
  auth.users → pets (user_id)
  ✅ Direct lookup O(1)

GET pet's social feed:
  pets → posts + stories
  pets → post_likes + comments
  ✅ Natural joins O(n)

GET pet's health records:
  pets → pet_symptoms
  pets → pet_medications → pet_medication_doses
  pets → pet_allergies
  pets → pet_vet_appointments
  pets → pet_vaccinations
  ✅ 1 pet = many health tables

GET chat thread messages:
  chat_threads (pet_id_1, pet_id_2)
  → messages (thread_id)
  → sender (sender_pet_id)
  ✅ Perfect for messaging UI

GET gamification stats:
  pets → pet_care_gamification (1-to-1)
  pets → pet_care_badge_unlocks
  pet_care_badge_unlocks → care_badge_definitions
  ✅ Fast badge+stats aggregate
```

---

## Security Analysis

### RLS (Row-Level Security) Status

**Current**: Enabled on 29/30 tables (96.7% coverage)

| Table | RLS | Notes |
|-------|-----|-------|
| All tables | ✅ | Enabled except auth.users |
| auth.users | ❌ | Managed by Supabase Auth |

### Recommended RLS Policies

#### For `profiles`
```sql
-- Users can only view their own profile
SELECT * FROM profiles WHERE id = auth.uid();

-- OR view public profiles
SELECT * FROM profiles WHERE is_public = true;
```

#### For `pets`
```sql
-- Users can view their own pets
SELECT * FROM pets WHERE user_id = auth.uid();

-- OR view public pets (is_public_owner = true)
SELECT * FROM pets WHERE is_public_owner = true;
```

#### For `posts`
```sql
-- Users can view posts from pets they own or publicly shared
SELECT * FROM posts p
WHERE p.pet_id IN (
  SELECT id FROM pets WHERE user_id = auth.uid()
)
OR p.pet_id IN (
  SELECT id FROM pets WHERE is_public_owner = true
);
```

#### For `messages`
```sql
-- Users only see messages in threads with their pets
SELECT * FROM messages m
WHERE m.thread_id IN (
  SELECT id FROM chat_threads ct
  WHERE ct.pet_id_1 IN (SELECT id FROM pets WHERE user_id = auth.uid())
  OR ct.pet_id_2 IN (SELECT id FROM pets WHERE user_id = auth.uid())
);
```

### Data Sensitivity Assessment

| Table | Sensitivity | Notes |
|-------|------------|-------|
| auth.users | 🔴 Critical | Password hashes, auth tokens |
| notifications | 🔴 Critical | Personal alerts |
| messages | 🟡 High | Private conversations |
| pet_symptoms, medications, allergies | 🟡 High | Health information (PII) |
| posts, stories, comments | 🟢 Medium | Semi-public social data |
| products, orders | 🟡 High | Payment & transaction data |
| pet_care_logs | 🟢 Low | Activity logs |

---

## Performance Considerations

### Current Bottlenecks & Recommendations

#### 1. **Posts Feed** 
**Problem**: Posts + likes + comments might have N+1 queries
**Solution**: 
```sql
-- Optimized query with JOINs
SELECT p.*, 
  COUNT(DISTINCT pl.pet_id) as like_count,
  COUNT(DISTINCT c.id) as comment_count
FROM posts p
LEFT JOIN post_likes pl ON p.id = pl.post_id
LEFT JOIN comments c ON p.id = c.post_id
WHERE p.pet_id IN (...)
GROUP BY p.id
ORDER BY p.created_at DESC;
```

#### 2. **Pet's Health Dashboard**
**Problem**: 8 health tables require separate queries
**Solution**:
```sql
-- Single query with CTEs
WITH latest_health AS (
  SELECT pet_id, 'medication' as type, count(*) FROM pet_medications WHERE pet_id = ? AND is_active
  UNION ALL
  SELECT pet_id, 'allergy', count(*) FROM pet_allergies WHERE pet_id = ?
  ...
)
SELECT * FROM latest_health;
```

#### 3. **Messaging Threads**
**Problem**: Listing threads + unread counts needs aggregation
**Solution**:
```sql
-- Thread summary with message count
SELECT ct.*,
  COUNT(DISTINCT m.id) as message_count,
  SUM(CASE WHEN NOT m.is_read THEN 1 ELSE 0 END) as unread_count,
  MAX(m.created_at) as last_message_at
FROM chat_threads ct
LEFT JOIN messages m ON ct.id = m.thread_id
GROUP BY ct.id;
```

### Index Strategy

#### High Priority (create immediately)
```sql
-- Pet-related lookups
CREATE INDEX idx_pets_user_id ON pets(user_id);
CREATE INDEX idx_posts_pet_id ON posts(pet_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_messages_thread_id ON messages(thread_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
```

#### Medium Priority
```sql
-- Health records
CREATE INDEX idx_pet_care_logs_pet_id_log_date ON pet_care_logs(pet_id, log_date DESC);
CREATE INDEX idx_pet_medications_pet_id_is_active ON pet_medications(pet_id, is_active);
CREATE INDEX idx_pet_activity_logs_pet_id ON pet_activity_logs(pet_id, logged_at DESC);
```

#### Low Priority
```sql
-- Notifications & follow relationships
CREATE INDEX idx_notifications_user_id_is_read ON notifications(user_id, is_read);
CREATE INDEX idx_follows_follower_user_id ON follows(follower_user_id);
```

---

## Scaling Capacity

### Estimated Row Counts by Growth Stage

#### Stage 1: MVP (Month 1-3)
```
pets: 100 - 1,000
posts: 500 - 5,000
messages: 1,000 - 10,000
pet_care_logs: 365+ per pet
Total rows: ~10K
```

#### Stage 2: Growth (Month 3-12)
```
pets: 10,000 - 100,000
posts: 50,000 - 500,000
messages: 100,000 - 1M
pet_care_logs: 3,650+ per pet (annual)
Total rows: ~1.5M
```

#### Stage 3: Scale (Year 2+)
```
pets: 100,000 - 1M+
posts: 500K - 5M+
messages: 1M - 10M+
pet_care_logs: 36,500+ per pet (annual)
Total rows: ~15M+
```

**Storage Estimate**: 
- Small: ~100 MB
- Medium: ~5-10 GB
- Large: ~50-100 GB

---

## Migration & Data Portability

### Current State
- **Database Status**: ACTIVE, NEW (no production data)
- **Backup Strategy**: Supabase automatic daily backups
- **Export Options**: 
  - SQL dump via Supabase CLI
  - Programmatic API export
  - CSV per-table export

### Export Paths
```bash
# Full SQL dump
supabase db dump --db-url "postgresql://..."

# Table-specific export
SELECT * FROM pets TO '/tmp/pets.csv' WITH (FORMAT csv);

# JSON export (for analytics)
SELECT row_to_json(t) FROM pets t;
```

---

## Recommendations

### ✅ What's Working Well

1. **Clean separation of concerns**: Social, health, care, gamification clearly separated
2. **Pet-centric design**: Natural hub for all features
3. **Flexible relationships**: Supports complex matching/following
4. **Comprehensive health tracking**: Full medication + allergy + vaccination coverage
5. **JSONB usage**: Tasks, badge data, product metadata flexibly stored

### 🔧 Areas for Improvement

1. **Add column-level comments**: Document field purposes in DB
2. **Implement cascading deletes explicitly**: Ensure data consistency
3. **Add check constraints**: Validate status enums, severity levels
4. **Partial indexes**: For common filters (is_active, is_public_owner)
5. **Materialized views**: For analytics (pet stats, engagement trends)
6. **Audit tables**: Track changes to health/medication records

### 📊 Suggested Additions (Future)

1. **Analytics table**: Daily aggregates (posts, messages, active_users)
2. **Subscription table**: For premium features/pet profiles
3. **Audit log table**: For regulatory compliance
4. **Report/issue table**: For bug reporting or content moderation
5. **Achievement milestones**: For extended gamification

---

## Conclusion

PetSphere's database is **well-architected, scalable, and feature-complete** for a modern pet social platform. The pet-centric hub design is elegant and enables rapid feature development. With proper RLS policies, index strategy, and query optimization, the database can scale to support millions of pets and users.

**Readiness for Production**: 🟢 **READY (with security review)**

**Next Steps**:
1. ✅ Implement RLS policies (see Security Analysis)
2. ✅ Create recommended indexes
3. ✅ Set up automated backups & monitoring
4. ✅ Performance test with synthetic data
5. ✅ Document API-to-database mappings

---

**Document Generated**: 2026-05-09  
**Database**: petsphere (PostgreSQL 17.6.1)  
**Region**: ap-southeast-1  
**Status**: ACTIVE_HEALTHY ✅
