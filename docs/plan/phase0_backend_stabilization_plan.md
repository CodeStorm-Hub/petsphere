# Phase 0 Continuation: Backend Stabilization & Schema Reconciliation

This plan outlines the steps to resolve the remaining P0 backend issues in the PetFolio application, specifically focusing on creating migrations for missing tables and establishing schema integrity tests.

## 1. Schema Generation & Migrations

We need to create migrations for the following 14+ tables that are referenced in the app code but missing from the Supabase `public` schema.

### 1.1 Adoption (Feature: community)
- `adoption_listings`: id, shelter_name, pet_name, species, breed, age_months, gender, description, image_url, adoption_fee, is_available, contact_email, contact_phone, location, created_at
- `adoption_applications`: id, listing_id, applicant_id, status, message, created_at

### 1.2 Community (Feature: community)
- `community_groups`: id, name, description, image_url, member_count, category, created_at
- `community_group_members`: id, group_id, user_id, role, joined_at

### 1.3 Lost & Found (Feature: community)
- `lost_and_found_reports`: id, type (lost/found), pet_name, description, location, image_url, contact_info, is_resolved, created_at, user_id

### 1.4 Knowledge Base (Feature: services)
- `knowledge_base_articles`: id, title, category, content, image_url, read_time_minutes, created_at

### 1.5 Gear Reviews (Feature: marketplace)
- `gear_reviews`: id, product_id, user_id, rating, content, created_at

### 1.6 Events (Feature: services)
- `pet_events`: id, title, description, location, date, time, image_url, is_active, created_at, type
- `pet_event_rsvps`: id, event_id, user_id, status, created_at

### 1.7 Expenses (Feature: care)
- `pet_expenses`: id, pet_id, category, amount, date, description, created_at

### 1.8 Insurance (Feature: services)
- `pet_insurance_claims`: id, pet_id, policy_number, amount, status, description, created_at

### 1.10 Nutrition (Feature: nutrition)
- `pet_nutrition_logs`: id, pet_id, food_name, amount, unit, date, time, created_at

### 1.11 Sitters (Feature: services)
- `pet_sitter_jobs`: id, title, description, location, price_per_hour, user_id, is_active, created_at

### 1.12 Training (Feature: training)
- `pet_training_progress`: id, pet_id, skill_name, progress_percent, last_practiced, created_at

### 1.13 Breed Identifier (Feature: services)
- `pet_breed_scans`: id, pet_id, result_breed, confidence, image_url, created_at

### 1.14 Health/Vaccinations (Feature: health)
- `vaccination_schedules`: id, pet_id, vaccine_name, due_date, status, created_at

## 2. Implementation Steps

1.  **Extract Schema Details**: Review each repository/model file to confirm exact column names and types.
2.  **Generate Migration SQL**: Create a comprehensive SQL file containing `CREATE TABLE` statements, Primary Keys, Foreign Keys, and RLS policies for each table.
3.  **Apply Migration**: Use `mcp:supabase:apply_migration` to update the Supabase project.
4.  **Schema Health Check Widget**: Implement a debug-only widget in the app that checks for the existence of all required tables on startup.
5.  **Integration Smoke Tests**: Create a simple test suite that traverses the routes corresponding to these tables to ensure they load without errors.

## 3. RLS Policy Strategy
Each table should have:
- `SELECT`: Public or Authenticated (depending on feature).
- `INSERT`: Authenticated with `user_id` check.
- `UPDATE/DELETE`: Authenticated with `user_id` check (owner only).

---
**Status**: Ready to extract schema details.
