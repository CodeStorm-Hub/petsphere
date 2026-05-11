# PerFolio — Complete Product & Database Architecture Documentation

Version: 2.0  
Platform: Flutter (Android, iOS, Web)  
Backend: Supabase + PostgreSQL  
Architecture Style: Multi-Module Social Pet Ecosystem SaaS  
Prepared For: PerFolio Product Refinement & Enterprise Scaling

---

# 1. Project Overview

## What is PerFolio?

PerFolio is a comprehensive cross-platform pet ecosystem application designed to combine:

- Pet social networking
- Pet wellness management
- AI-powered pet intelligence
- Community engagement
- Pet matchmaking
- Marketplace/e-commerce
- Adoption ecosystem
- Lost & found services
- Gamification
- Pet lifestyle management

The application behaves like:

| Comparable Product | Similarity |
|---|---|
| Instagram | Pet social networking |
| Fitbit | Pet wellness tracking |
| Tinder | Pet matchmaking |
| Amazon | Pet marketplace |
| Reddit/Facebook Groups | Pet communities |
| Uber/TaskRabbit | Pet sitter services |
| Duolingo | Gamified pet care |

---

# 2. Current System Problems

The existing schema is ambitious but has architectural inconsistencies.

## Existing Issues Identified

---

## 2.1 Data Integrity Problems

### Problem
Excessive use of TEXT fields.

### Examples
- status
- type
- category
- role
- visibility

### Risk
- Invalid states
- Typos
- Inconsistent analytics
- Hard filtering

### Solution
Use PostgreSQL ENUMs.

---

## 2.2 Poor Normalization

### Problem
Arrays and JSONB used as relational data.

### Examples
- products.images
- orders.items
- posts.tagged_pet_ids

### Risk
- No referential integrity
- Difficult querying
- Poor indexing

### Solution
Replace with relational tables.

---

## 2.3 Missing Constraints

### Problem
No CHECK validations.

### Examples
- negative weights
- invalid ratings
- invalid percentages

### Solution
Add CHECK constraints.

---

## 2.4 Weak Ownership Design

### Problem
Inconsistent ownership.

Some tables:
- user_id

Others:
- pet_id

Others:
- both

### Solution
Standardize ownership hierarchy.

---

## 2.5 Scalability Risks

### Problem
No partitioning/index strategy for large tables.

### High Risk Tables
- posts
- comments
- notifications
- messages
- activity logs

---

## 2.6 Missing Audit System

### Problem
Most tables lack:
- updated_at
- deleted_at
- audit tracking

### Solution
Universal audit architecture.

---

# 3. Refined Product Architecture

---

## 3.1 Logical Domain Architecture

```txt
auth/
social/
pets/
health/
care/
commerce/
community/
adoption/
analytics/
system/
```

---

## 3.2 Recommended Supabase Schema Structure

| Schema    | Responsibility         |
| --------- | ---------------------- |
| auth      | Authentication         |
| users     | User profiles/settings |
| pets      | Pet ecosystem          |
| social    | Feed/social            |
| messaging | Chat                   |
| health    | Medical records        |
| commerce  | Marketplace            |
| community | Groups/events          |
| adoption  | Adoption               |
| ai        | AI services            |
| analytics | Reporting              |
| system    | Notifications/logging  |

---

# 4. Refined Core Database Design

---

## 4.1 Base Audit Columns

Every table MUST include:

```sql
id UUID PRIMARY KEY
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
deleted_at TIMESTAMPTZ NULL
created_by UUID
updated_by UUID
```

---

## 4.2 Standard ENUM Types

---

### User Roles

```sql
CREATE TYPE user_role AS ENUM (
  'user',
  'vendor',
  'moderator',
  'admin',
  'shelter'
);
```

---

### Post Types

```sql
CREATE TYPE post_type AS ENUM (
  'image',
  'video',
  'story',
  'reel'
);
```

---

### Notification Types

```sql
CREATE TYPE notification_type AS ENUM (
  'like',
  'comment',
  'follow',
  'message',
  'match',
  'system',
  'event'
);
```

---

### Match Status

```sql
CREATE TYPE match_status AS ENUM (
  'pending',
  'accepted',
  'rejected',
  'blocked'
);
```

---

# 5. Refined Database Modules

---

## MODULE 1 — USERS

---

### Table: users.profiles

### *Purpose*

Stores human user information.

---

### *Columns*

| Column      | Type        |
| ----------- | ----------- |
| id          | UUID        |
| username    | TEXT UNIQUE |
| full_name   | TEXT        |
| avatar_url  | TEXT        |
| bio         | TEXT        |
| location    | TEXT        |
| role        | user_role   |
| is_verified | BOOLEAN     |
| is_private  | BOOLEAN     |

---

### *CRUD Operations*

### Create

* Register profile

### Read

* View profiles

### Update

* Edit profile

### Delete

* Soft delete account

---

## MODULE 2 — PETS

---

### Table: pets.pets

### *Purpose*

Core pet identity table.

---

### *Columns*

| Column            | Type    |
| ----------------- | ------- |
| id                | UUID    |
| owner_id          | UUID    |
| name              | TEXT    |
| species           | TEXT    |
| breed             | TEXT    |
| gender            | TEXT    |
| birth_date        | DATE    |
| bio               | TEXT    |
| weight_kg         | NUMERIC |
| profile_image_url | TEXT    |
| visibility        | TEXT    |

---

### Relationships

```txt
users.profiles
  └── pets.pets
```

---

### CRUD

### Create

* Add pet profile

### Read

* View pet

### Update

* Edit pet details

### Delete

* Archive pet

---

## MODULE 3 — PET MEDIA

---

### Table: pets.pet_media

### *Purpose*

Normalized media storage.

---

### *Columns*

| Column     | Type    |
| ---------- | ------- |
| id         | UUID    |
| pet_id     | UUID    |
| media_url  | TEXT    |
| media_type | TEXT    |
| sort_order | INTEGER |

---

## MODULE 4 — SOCIAL FEED

---

### Table: social.posts

---

#### Columns

| Column     | Type      |
| ---------- | --------- |
| id         | UUID      |
| pet_id     | UUID      |
| caption    | TEXT      |
| post_type  | post_type |
| visibility | TEXT      |

---

### Table: social.post_media

---

### Columns

| Column     | Type |
| ---------- | ---- |
| id         | UUID |
| post_id    | UUID |
| media_url  | TEXT |
| media_type | TEXT |

---

### Table: social.comments

---

### Columns

| Column  | Type |
| ------- | ---- |
| id      | UUID |
| post_id | UUID |
| pet_id  | UUID |
| comment | TEXT |

---

### Table: social.post_likes

---

### Constraints

```sql
UNIQUE(post_id, pet_id)
```

---

### CRUD Operations

### Posts

* Create post
* View feed
* Update caption
* Delete post

### Comments

* Add comment
* Edit comment
* Delete comment

### Likes

* Like/unlike

---

## MODULE 5 — FOLLOW SYSTEM

---

### Table: social.follows

---

### Columns

| Column           | Type |
| ---------------- | ---- |
| follower_pet_id  | UUID |
| following_pet_id | UUID |

---

### Constraints

```sql
UNIQUE(follower_pet_id, following_pet_id)
```

---

## MODULE 6 — MATCHING

---

### Table: social.match_requests

---

### Constraints

```sql
UNIQUE(sender_pet_id, receiver_pet_id)
```

---

### User Flow

```txt
Discover Pet
→ Send Match
→ Accept/Reject
→ Create Chat Thread
```

---

## MODULE 7 — MESSAGING

---

### Table: messaging.chat_threads

---

### Columns

| Column     | Type |
| ---------- | ---- |
| id         | UUID |
| pet_one_id | UUID |
| pet_two_id | UUID |

---

### Table: messaging.messages

---

### Columns

| Column        | Type |
| ------------- | ---- |
| id            | UUID |
| thread_id     | UUID |
| sender_pet_id | UUID |
| content       | TEXT |
| message_type  | TEXT |

---

### Features

* Real-time messaging
* Read receipts
* Media uploads
* Typing indicators

---

## MODULE 8 — HEALTH SYSTEM

---

### Tables

```txt
pet_weight_logs
pet_activity_logs
pet_vaccinations
pet_medications
pet_medication_doses
pet_vet_appointments
pet_allergies
pet_symptoms
pet_nutrition_logs
```

---

### Health User Flow

```txt
Pet Dashboard
→ Add Health Data
→ Generate Trends
→ AI Recommendations
→ Reminder Notifications
```

---

## MODULE 9 — GAMIFICATION

---

### Tables

```txt
care_badge_definitions
pet_care_gamification
pet_care_badge_unlocks
```

---

### Features

* Daily streaks
* XP system
* Care achievements
* Progress levels

---

## MODULE 10 — MARKETPLACE

---

### Refined Structure

---

### products

Core product table.

---

### product_images

Normalized images.

---

### product_categories

Category taxonomy.

---

### orders

Order header.

---

### order_items

Normalized order lines.

---

### gear_reviews

Review system.

---

### Marketplace Flow

```txt
Browse Products
→ Add to Cart
→ Checkout
→ Payment
→ Order Tracking
→ Review Product
```

---

## MODULE 11 — COMMUNITY

---

### Tables

```txt
community_groups
community_group_members
group_posts
group_comments
```

---

### Features

* Public/private groups
* Moderation
* Group feeds
* Membership approvals

---

## MODULE 12 — EVENTS

---

### Tables

```txt
pet_events
pet_event_rsvps
```

---

### Features

* Event creation
* RSVP management
* Event reminders

---

### MODULE 13 — ADOPTION

---

### Tables

```txt
adoption_listings
adoption_applications
```

---

### Adoption Flow

```txt
Shelter Creates Listing
→ User Applies
→ Shelter Reviews
→ Approval/Rejection
→ Messaging
```

---

## MODULE 14 — LOST & FOUND

---

### Features

* Missing pet alerts
* Geo-location
* Reward management
* Community reporting

---

## MODULE 15 — AI SERVICES

---

### Tables

```txt
pet_breed_scans
ai_health_predictions
ai_behavior_analysis
```

---

### Features

* Breed detection
* Health recommendations
* Behavior analysis

---

## MODULE 16 — NOTIFICATIONS

---

### Refined Notifications

### Table: system.notifications

---

### Features

* Push notifications
* Email notifications
* In-app notifications
* Read/unread states

---

# 6. Global CRUD Matrix

| Module       | Create | Read | Update      | Delete |
| ------------ | ------ | ---- | ----------- | ------ |
| Users        | ✅      | ✅    | ✅           | Soft   |
| Pets         | ✅      | ✅    | ✅           | Soft   |
| Posts        | ✅      | ✅    | ✅           | Hard   |
| Comments     | ✅      | ✅    | ✅           | Hard   |
| Messages     | ✅      | ✅    | ❌           | Soft   |
| Orders       | ✅      | ✅    | Status only | ❌      |
| Vaccinations | ✅      | ✅    | ✅           | Soft   |
| Events       | ✅      | ✅    | ✅           | Soft   |
| Adoption     | ✅      | ✅    | Status only | ❌      |

---

# 7. Recommended Indexing Strategy

---

## Social

```sql
CREATE INDEX idx_posts_pet_created
ON social.posts(pet_id, created_at DESC);
```

---

## Messages

```sql
CREATE INDEX idx_messages_thread
ON messaging.messages(thread_id, created_at DESC);
```

---

## Notifications

```sql
CREATE INDEX idx_notifications_user
ON system.notifications(user_id, is_read);
```

---

# 8. Row Level Security Strategy

---

# Rules

## Users

Can only modify their own data.

## Pets

Owner-only editing.

## Posts

Public read/private control.

## Messages

Only participants can access.

## Orders

Buyer/vendor restricted.

---

# 9. Refined User Flows

---

## New User Flow

```txt
Install App
→ Sign Up
→ Create Profile
→ Add Pet
→ Follow Pets
→ Create First Post
→ Enable Notifications
```

---

## Social Flow

```txt
Feed
→ Like
→ Comment
→ Follow
→ Match
→ Chat
```

---

## Wellness Flow

```txt
Pet Dashboard
→ Add Logs
→ Track Progress
→ Earn Badges
→ Receive Insights
```

---

## Commerce Flow

```txt
Marketplace
→ Product
→ Cart
→ Payment
→ Shipping
→ Review
```

---

## Community Flow

```txt
Join Group
→ Participate
→ Attend Events
→ Share Content
```

---

# 10. Flutter Architecture Recommendation

---

# Recommended State Management

| Technology       | Purpose          |
| ---------------- | ---------------- |
| Riverpod         | State management |
| GoRouter         | Routing          |
| Freezed          | Immutable models |
| Supabase Flutter | Backend          |
| Drift/Hive       | Offline cache    |

---

# 11. Backend Architecture

---

## Supabase Services

| Service        | Usage            |
| -------------- | ---------------- |
| Auth           | Authentication   |
| Database       | PostgreSQL       |
| Realtime       | Chat/live feed   |
| Storage        | Media            |
| Edge Functions | AI/payment logic |

---

# 12. Performance Recommendations

---

## High Priority

### Add:

* Partitioning
* Caching
* Materialized views
* Background jobs

---

# 13. Enterprise Enhancements

---

## Add Future Tables

```txt
audit_logs
moderation_reports
content_reports
search_index
analytics_events
subscription_plans
payment_transactions
feature_flags
```

---

# 14. Security Enhancements

---

## Required

* Strict RLS
* Signed URLs
* JWT validation
* API rate limiting
* Content moderation
* Device tracking

---

# 15. Final Product Positioning

PerFolio is evolving into:

## A Pet Super App

Combining:

* social networking,
* wellness tracking,
* AI intelligence,
* commerce,
* community,
* and pet lifestyle management

inside a single cross-platform ecosystem.

---

# 16. Final Assessment

## Current Stage

Advanced MVP / Early Production

## Architecture Quality

Good foundation with scalability issues.

## After Refinement

Production-grade scalable SaaS architecture.

## Long-Term Potential

Very high.

Potential expansion:

* veterinary integrations
* pet insurance
* AI diagnostics
* subscription revenue
* enterprise shelter management
* global pet social network

---
