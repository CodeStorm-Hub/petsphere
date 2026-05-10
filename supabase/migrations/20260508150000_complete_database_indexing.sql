-- Comprehensive indexing for PetSphere performance optimization
-- Addresses pending indexes for all critical tables (28 total)
-- This migration fixes column name mismatches from Phase 1.3

-- ────────────────────────────────────────────────────────────────────────────
-- USERS TABLE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_users_created_at
  ON public.users (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_users_email_unique
  ON public.users (email);


-- ────────────────────────────────────────────────────────────────────────────
-- PETS TABLE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_pets_user_id
  ON public.pets (user_id);

CREATE INDEX IF NOT EXISTS idx_pets_created_at
  ON public.pets (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_pets_animal_type
  ON public.pets (animal_type);

CREATE INDEX IF NOT EXISTS idx_pets_is_public
  ON public.pets (is_public) WHERE is_public = true;


-- ────────────────────────────────────────────────────────────────────────────
-- POSTS TABLE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_posts_pet_id
  ON public.posts (pet_id);

CREATE INDEX IF NOT EXISTS idx_posts_created_at
  ON public.posts (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_posts_pet_created_at
  ON public.posts (pet_id, created_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- STORIES TABLE INDEXES (24-hour ephemeral content)
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_stories_pet_id
  ON public.stories (pet_id);

CREATE INDEX IF NOT EXISTS idx_stories_expires_at
  ON public.stories (expires_at);

CREATE INDEX IF NOT EXISTS idx_stories_pet_expires_at
  ON public.stories (pet_id, expires_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- COMMENTS TABLE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_comments_post_id
  ON public.comments (post_id);

CREATE INDEX IF NOT EXISTS idx_comments_pet_id
  ON public.comments (pet_id);

CREATE INDEX IF NOT EXISTS idx_comments_created_at
  ON public.comments (created_at ASC);

CREATE INDEX IF NOT EXISTS idx_comments_post_created_at
  ON public.comments (post_id, created_at ASC);


-- ────────────────────────────────────────────────────────────────────────────
-- POST LIKES (many-to-many) INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id
  ON public.post_likes (post_id);

CREATE INDEX IF NOT EXISTS idx_post_likes_pet_id
  ON public.post_likes (pet_id);


-- ────────────────────────────────────────────────────────────────────────────
-- FOLLOWS (social graph) INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_follows_follower_pet_id
  ON public.follows (follower_pet_id);

CREATE INDEX IF NOT EXISTS idx_follows_followee_pet_id
  ON public.follows (followee_pet_id);

CREATE INDEX IF NOT EXISTS idx_follows_both
  ON public.follows (follower_pet_id, followee_pet_id);


-- ────────────────────────────────────────────────────────────────────────────
-- MATCH REQUESTS (pet dating/discovery) INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_match_requests_sender_pet_id
  ON public.match_requests (sender_pet_id);

CREATE INDEX IF NOT EXISTS idx_match_requests_receiver_pet_id
  ON public.match_requests (receiver_pet_id);

CREATE INDEX IF NOT EXISTS idx_match_requests_status
  ON public.match_requests (status);

CREATE INDEX IF NOT EXISTS idx_match_requests_created_at
  ON public.match_requests (created_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- MESSAGES (1-on-1 chat) INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_messages_chat_thread_id
  ON public.messages (chat_thread_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender_pet_id
  ON public.messages (sender_pet_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at
  ON public.messages (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_thread_created_at
  ON public.messages (chat_thread_id, created_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- CHAT THREADS INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_chat_threads_updated_at
  ON public.chat_threads (updated_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- NOTIFICATIONS TABLE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_notifications_user_id
  ON public.notifications (user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
  ON public.notifications (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created_at
  ON public.notifications (user_id, created_at DESC);


-- ────────────────────────────────────────────────────────────────────────────
-- ORDERS & MARKETPLACE INDEXES
-- ────────────────────────────────────────────────────────────────────────────
-- Already created in 20260504140000_review_remediation_rls_storage_posts_products.sql:
-- products_category_idx, products_created_at_idx
-- Additional:
CREATE INDEX IF NOT EXISTS idx_orders_user_id
  ON public.orders (user_id);

CREATE INDEX IF NOT EXISTS idx_orders_created_at
  ON public.orders (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_orders_status
  ON public.orders (status);


-- ────────────────────────────────────────────────────────────────────────────
-- PET CARE & HEALTH INDEXES
-- ────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_pet_care_logs_pet_id
  ON public.pet_care_logs (pet_id);

CREATE INDEX IF NOT EXISTS idx_pet_care_logs_log_date
  ON public.pet_care_logs (log_date DESC);

CREATE INDEX IF NOT EXISTS idx_pet_care_logs_pet_date
  ON public.pet_care_logs (pet_id, log_date DESC);

-- Health: symptoms, vaccinations, appointments, weight logs
CREATE INDEX IF NOT EXISTS idx_pet_health_symptoms_pet_id
  ON public.pet_health_symptoms (pet_id);

CREATE INDEX IF NOT EXISTS idx_pet_health_vaccinations_pet_id
  ON public.pet_health_vaccinations (pet_id);

CREATE INDEX IF NOT EXISTS idx_pet_vet_appointments_pet_id
  ON public.pet_vet_appointments (pet_id);

CREATE INDEX IF NOT EXISTS idx_pet_weight_logs_pet_id
  ON public.pet_weight_logs (pet_id);


-- ────────────────────────────────────────────────────────────────────────────
-- SUMMARY: Total indexes created
-- ────────────────────────────────────────────────────────────────────────────
-- users: 2
-- pets: 4
-- posts: 3
-- stories: 3
-- comments: 4
-- post_likes: 2
-- follows: 3
-- match_requests: 4
-- messages: 4
-- chat_threads: 1
-- notifications: 3
-- orders & marketplace: 3
-- pet_care & health: 7
-- ────────────────────────────────────────────────────────────────────────────
-- TOTAL: 43 indexes (28 strategic + 15 additional for comprehensive coverage)
-- Created at: 2026-05-08
-- Phase: 1.3 Database Indexing (Complete)
