# PetSphere Database Schema Documentation

**Project**: PetSphere  
**Database**: PostgreSQL 17 (Supabase)  
**Region**: ap-southeast-1  
**Status**: ACTIVE_HEALTHY  
**Generated**: 2026-05-09

---

## Table of Contents
1. [Overview](#overview)
2. [Core Tables](#core-tables)
3. [Social Features](#social-features)
4. [Matching & Communication](#matching--communication)
5. [Health & Care Management](#health--care-management)
6. [Gamification System](#gamification-system)
7. [Marketplace](#marketplace)
8. [User Management](#user-management)
9. [Statistics](#statistics)
10. [Key Relationships](#key-relationships)

---

## Overview

PetSphere database contains **30 tables** organized into functional domains:

- **User & Profile Management**: profiles, follows
- **Pet Core**: pets, pet care logs
- **Social Features**: posts, stories, comments, post_likes
- **Matching & Dating**: match_requests
- **Messaging**: chat_threads, messages
- **Health & Wellness**: Medications, allergies, symptoms, vaccinations, vet appointments
- **Care Tracking**: activity logs, dental logs, weight logs, parasite prevention
- **Gamification**: badges, unlocks, streaks, points
- **Marketplace**: products, orders
- **Notifications & Tokens**: notifications, user_fcm_tokens
- **Administrative**: waitlist

---

## Core Tables

### `auth.users` (Supabase Auth)
**Description**: Authentication and user accounts (managed by Supabase Auth)

| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | PRIMARY KEY |
| email | text | UNIQUE |
| (other auth fields) | - | - |

**Relations**: Referenced by profiles, pets, notifications, orders, products, follows, and many health tables

---

### `profiles`
**Description**: User profile information including bio, profile image, and care badges

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY, FK→auth.users | |
| name | text | NULLABLE | |
| profile_image_url | text | NULLABLE | |
| bio | text | NULLABLE | |
| location | text | NULLABLE | |
| public_care_badge_slugs | text[] | NULLABLE | '{}' |
| show_care_badges_on_profile | boolean | NULLABLE | true |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pets`
**Description**: Pet profiles - core entity for the platform

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| user_id | uuid | FK→auth.users | |
| name | text | | |
| breed | text | NULLABLE | |
| animal_type | text | NULLABLE | |
| age | integer | NULLABLE | |
| bio | text | NULLABLE | |
| profile_image_url | text | NULLABLE | |
| images | text[] | NULLABLE | '{}' |
| is_public_owner | boolean | NULLABLE | true |
| is_breeding_listed | boolean | NULLABLE | false |
| is_verified | boolean | NULLABLE | false |
| is_vaccinated | boolean | NULLABLE | false |
| is_care_listed | boolean | NULLABLE | false |
| monthly_budget | numeric | NULLABLE | 1000.0 |
| daily_calorie_goal | integer | NULLABLE | |
| daily_water_goal_cups | integer | NULLABLE | |
| weight_lbs | numeric | NULLABLE | |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled  
**Relationships**: 25+ tables reference this as primary entity

---

## Social Features

### `posts`
**Description**: Pet social media posts with images, captions, and locations

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| media_url | text | | |
| caption | text | NULLABLE | |
| location | text | NULLABLE | |
| tagged_pet_ids | uuid[] | NULLABLE | '{}' |
| tagged_pet_names | text[] | NULLABLE | '{}' |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `post_likes`
**Description**: Likes on posts (pet-to-post engagement)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| post_id | uuid | PRIMARY KEY, FK→posts | |
| pet_id | uuid | PRIMARY KEY, FK→pets | |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `comments`
**Description**: Comments on posts

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| post_id | uuid | FK→posts | |
| pet_id | uuid | FK→pets | |
| text | text | | |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `stories`
**Description**: Ephemeral stories (24-hour expiration)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| media_url | text | | |
| media_type | text | NULLABLE | 'image' |
| caption | text | NULLABLE | |
| created_at | timestamptz | NULLABLE | now() |
| expires_at | timestamptz | | now() + interval '24 hours' |
| is_seen | boolean | NULLABLE | false |

**RLS**: Enabled

---

## Matching & Communication

### `match_requests`
**Description**: Pet matching/dating requests with status tracking

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| sender_pet_id | uuid | FK→pets | |
| receiver_pet_id | uuid | FK→pets | |
| status | text | CHECK: pending/matched/rejected | 'pending' |
| created_at | timestamptz | NULLABLE | now() |
| updated_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `chat_threads`
**Description**: Conversation threads between two pets

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id_1 | uuid | FK→pets | |
| pet_id_2 | uuid | FK→pets | |
| created_at | timestamptz | NULLABLE | now() |
| updated_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `messages`
**Description**: Individual messages in a chat thread

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| thread_id | uuid | FK→chat_threads | |
| sender_pet_id | uuid | FK→pets | |
| text | text | NULLABLE | |
| media_url | text | NULLABLE | |
| message_type | text | NULLABLE | 'text' |
| is_read | boolean | NULLABLE | false |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

## Health & Care Management

### `pet_symptoms`
**Description**: Symptom logs for health tracking

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| symptom_name | text | | |
| severity | text | | |
| notes | text | NULLABLE | |
| logged_at | timestamptz | | now() |

**RLS**: Enabled

---

### `pet_medications`
**Description**: Medication prescriptions and schedule

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| name | text | | |
| dosage | text | | |
| frequency | text | | |
| start_date | date | | CURRENT_DATE |
| end_date | date | NULLABLE | |
| notes | text | NULLABLE | |
| is_active | boolean | NULLABLE | true |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pet_medication_doses`
**Description**: Individual medication administration records

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| medication_id | uuid | FK→pet_medications | |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| taken_at | timestamptz | NULLABLE | now() |
| notes | text | NULLABLE | |

**RLS**: Enabled

---

### `pet_allergies`
**Description**: Known allergies and reactions

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| allergen | text | | |
| reaction | text | NULLABLE | |
| severity | text | NULLABLE | CHECK: low/medium/high/critical |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pet_parasite_prevention`
**Description**: Parasite treatment and prevention records

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| prevention_type | text | | |
| product_name | text | NULLABLE | |
| administered_at | date | | CURRENT_DATE |
| next_due_at | date | NULLABLE | |
| notes | text | NULLABLE | |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pet_dental_logs`
**Description**: Dental care and checkup records

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| condition_description | text | NULLABLE | |
| brushed_at | timestamptz | NULLABLE | now() |
| notes | text | NULLABLE | |

**RLS**: Enabled

---

### `pet_activity_logs`
**Description**: Exercise and activity tracking

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| user_id | uuid | FK→auth.users | |
| activity_type | text | | |
| duration_minutes | integer | NULLABLE | 0 |
| distance_meters | numeric | NULLABLE | |
| notes | text | NULLABLE | |
| logged_at | timestamptz | | now() |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

### `pet_care_logs`
**Description**: Daily care activities (feeding, water, tasks)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| log_date | date | | CURRENT_DATE |
| breakfast_fed | boolean | | false |
| dinner_fed | boolean | | false |
| breakfast_kcal | integer | | 250 |
| dinner_kcal | integer | | 250 |
| breakfast_food | text | | 'Dry Kibble - 1 cup' |
| dinner_food | text | | 'Wet Food - 1/2 can' |
| water_cups | integer | | 0 |
| tasks | jsonb | | [{walk, med, brush}] |
| mood | text | NULLABLE | |
| daily_calorie_goal | integer | | 500 |
| daily_water_goal_cups | integer | | 8 |
| is_treat | boolean | NULLABLE | false |
| created_at | timestamptz | | now() |
| updated_at | timestamptz | | now() |

**RLS**: Enabled

---

### `pet_weight_logs`
**Description**: Weight tracking over time

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| log_date | date | | CURRENT_DATE |
| weight_lbs | numeric | | |
| notes | text | NULLABLE | |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

### `pet_vet_appointments`
**Description**: Veterinary appointment scheduling and records

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| title | text | | |
| doctor | text | NULLABLE | |
| scheduled_at | timestamptz | | |
| notes | text | NULLABLE | |
| is_completed | boolean | NULLABLE | false |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

### `pet_vaccinations`
**Description**: Vaccination record and schedule

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| vaccine_name | text | | |
| status | text | CHECK: scheduled/completed | 'scheduled' |
| completed_on | date | NULLABLE | |
| scheduled_for | date | NULLABLE | |
| notes | text | NULLABLE | |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

## Gamification System

### `care_badge_definitions`
**Description**: Master list of achievement badges (6 total)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| slug | text | PRIMARY KEY | |
| title | text | | |
| description | text | NULLABLE | |
| icon_emoji | text | NULLABLE | |
| sort_order | integer | NULLABLE | 0 |

**RLS**: Enabled

---

### `pet_care_gamification`
**Description**: Gamification stats and streaks per pet

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| pet_id | uuid | PRIMARY KEY, FK→pets | |
| total_care_points | integer | NULLABLE | 0 |
| current_streak | integer | NULLABLE | 0 |
| best_streak | integer | NULLABLE | 0 |
| last_care_date | date | NULLABLE | |
| health_score | integer | NULLABLE | 100 |
| treats_today | integer | NULLABLE | 0 |
| last_treat_date | date | NULLABLE | |
| last_medication_date | date | NULLABLE | |
| daily_point_award_date | date | NULLABLE | |
| daily_point_award_accrued | integer | | 0 |
| updated_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pet_care_badge_unlocks`
**Description**: Badge unlock history (when badges were earned)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| pet_id | uuid | FK→pets | |
| badge_slug | text | FK→care_badge_definitions | |
| unlocked_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `pet_care_onboarding`
**Description**: Onboarding data and completion status per pet

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| pet_id | uuid | PRIMARY KEY, FK→pets | |
| data | jsonb | NULLABLE | '{}' |
| is_completed | boolean | NULLABLE | false |
| updated_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

## Marketplace

### `products`
**Description**: Marketplace product listings

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| name | text | | |
| price | numeric | | 0 |
| vendor_id | uuid | FK→auth.users | |
| description | text | | '' |
| images | jsonb | | '[]' |
| stock | integer | | 0 |
| category | text | | '' |
| rating | numeric | | 0 |
| review_count | integer | | 0 |
| tags | jsonb | | '[]' |
| is_bestseller | boolean | | false |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

### `orders`
**Description**: Marketplace orders

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| user_id | uuid | FK→auth.users | |
| items | jsonb | | '[]' |
| total | numeric | | 0 |
| status | text | | 'pending' |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

## User Management

### `notifications`
**Description**: In-app notifications for users

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| user_id | uuid | FK→auth.users | |
| title | text | | |
| message | text | | |
| type | text | NULLABLE | |
| data | jsonb | NULLABLE | '{}' |
| is_read | boolean | NULLABLE | false |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `follows`
**Description**: Follow relationships (users and pets)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| follower_user_id | uuid | FK→auth.users | |
| followed_user_id | uuid | NULLABLE, FK→auth.users | |
| followed_pet_id | uuid | NULLABLE, FK→pets | |
| created_at | timestamptz | | now() |

**RLS**: Enabled

---

### `user_fcm_tokens`
**Description**: Firebase Cloud Messaging tokens for push notifications

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| user_id | uuid | PRIMARY KEY, FK→auth.users | |
| fcm_token | text | PRIMARY KEY | |
| device_type | text | NULLABLE | |
| last_updated_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

### `waitlist`
**Description**: Waitlist for app sign-ups

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | uuid | PRIMARY KEY | gen_random_uuid() |
| email | text | UNIQUE | |
| pet_type | text | NULLABLE | |
| interest_areas | text[] | NULLABLE | |
| status | text | NULLABLE | 'pending' |
| created_at | timestamptz | NULLABLE | now() |

**RLS**: Enabled

---

## Statistics

### Table Count: 30 tables

### By Domain:
- **User & Auth**: 2 tables (auth.users + profiles)
- **Core Pet Features**: 1 table (pets)
- **Social Features**: 4 tables (posts, post_likes, comments, stories)
- **Matching & Messaging**: 4 tables (match_requests, chat_threads, messages)
- **Health Management**: 8 tables (symptoms, medications, doses, allergies, parasite prevention, dental, vaccinations, vet appointments)
- **Care Tracking**: 3 tables (activity logs, care logs, weight logs)
- **Gamification**: 4 tables (badge definitions, gamification stats, badge unlocks, onboarding)
- **Marketplace**: 2 tables (products, orders)
- **User Management**: 3 tables (notifications, follows, user_fcm_tokens)
- **Other**: 1 table (waitlist)

### Key Metrics:
- **Total Foreign Keys**: 75+
- **RLS Enabled**: 29 out of 30 tables
- **Primary Entities**: pets (26 dependent tables), auth.users (10+ dependent tables)
- **Array Fields**: 15+ (text[], uuid[])
- **JSONB Fields**: 7 (flexible data storage)
- **Temporal Fields**: All tables have timestamp tracking

---

## Key Relationships

### Pet-centric relationships (PETS is the hub):
```
pets ← 26 related tables:
  ├── User/Owner: auth.users, profiles
  ├── Social: posts, comments, post_likes, stories
  ├── Matching: match_requests (bidirectional), follows
  ├── Messaging: chat_threads, messages
  ├── Health: symptoms, medications, medication_doses, allergies, 
  │           parasite_prevention, dental_logs, vaccinations, vet_appointments
  ├── Care: pet_care_logs, weight_logs, activity_logs
  └── Gamification: pet_care_gamification, pet_care_badge_unlocks, pet_care_onboarding
```

### User-centric relationships (AUTH.USERS is auth hub):
```
auth.users → 10+ related tables:
  ├── Profile: profiles
  ├── Ownership: pets
  ├── Social: follows, notifications
  ├── Marketplace: products (vendor), orders
  ├── Health logs: symptoms, medications, medication_doses, allergies,
  │               parasite_prevention, dental_logs, activity_logs
  ├── Messaging: Push tokens (user_fcm_tokens)
  └── Waitlist: waitlist
```

### Many-to-many patterns:
- **match_requests**: pet ↔ pet (bidirectional)
- **chat_threads**: pet ↔ pet (conversation between two pets)
- **post_likes**: post ↔ pet (engagement)
- **comments**: post ↔ pet (engagement)
- **follows**: user ↔ (user or pet) (flexible follow model)
- **pet_care_badge_unlocks**: pet ↔ badge (achievement history)

---

## Row-Level Security (RLS)

**Status**: Enabled on 29/30 tables (all except auth.users which is Supabase-managed)

RLS policies should define:
- Users can only view their own data and public pet profiles
- Pets belong to their owner (user_id)
- Followers can view followed pets
- Messages only visible to involved pets' owners

---

## Backup & Export Info

- **Database Version**: PostgreSQL 17.6.1
- **Backup Strategy**: Supabase automatic daily backups
- **Total Tables**: 30
- **Total Columns**: ~200+
- **Estimated Data Volume**: Grows with user-generated content (posts, logs, messages)

---

**Last Updated**: 2026-05-09  
**Database Status**: ACTIVE_HEALTHY  
**Next Review**: Recommended quarterly
