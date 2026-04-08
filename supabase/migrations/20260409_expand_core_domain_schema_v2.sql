begin;

-- Align profiles with app expectations
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists profile_image_url text;

update public.profiles p
set email = u.email
from auth.users u
where p.id = u.id
  and p.email is null;

-- Add updated_at where useful for sync/UIs
alter table public.chat_threads add column if not exists updated_at timestamptz;
update public.chat_threads
set updated_at = coalesce(updated_at, created_at, now())
where updated_at is null;
alter table public.chat_threads alter column updated_at set default now();

alter table public.orders add column if not exists updated_at timestamptz;
update public.orders
set updated_at = coalesce(updated_at, created_at, now())
where updated_at is null;
alter table public.orders alter column updated_at set default now();

-- Extend messages for richer chat capabilities
alter table public.messages add column if not exists message_type text;
update public.messages set message_type = 'text' where message_type is null;
alter table public.messages alter column message_type set default 'text';
alter table public.messages add column if not exists media_url text;
alter table public.messages add column if not exists edited_at timestamptz;
alter table public.messages add column if not exists delivered_at timestamptz;

-- Create pet listings (Discovery "List Pet" persistence)
create table if not exists public.pet_listings (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null unique references public.pets(id) on delete cascade,
  listed_by_user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'active',
  title text,
  description text,
  preferred_animal_type text,
  preferred_breed text,
  min_age integer,
  max_age integer,
  location_text text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pet_listings_status_check check (status in ('active','paused','closed')),
  constraint pet_listings_age_range_check check (
    min_age is null or max_age is null or min_age <= max_age
  )
);

-- Create canonical matches table
create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  request_id uuid unique references public.match_requests(id) on delete set null,
  pet_id_1 uuid not null references public.pets(id) on delete cascade,
  pet_id_2 uuid not null references public.pets(id) on delete cascade,
  status text not null default 'active',
  created_by_user_id uuid references public.profiles(id) on delete set null,
  matched_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint matches_distinct_pets_check check (pet_id_1 <> pet_id_2),
  constraint matches_status_check check (status in ('active','archived','blocked'))
);

create unique index if not exists matches_pair_unique_idx
  on public.matches (least(pet_id_1, pet_id_2), greatest(pet_id_1, pet_id_2));

-- Notifications table for cross-feature user alerts
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_pet_id uuid references public.pets(id) on delete set null,
  type text not null,
  title text not null,
  body text,
  entity_type text,
  entity_id uuid,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  constraint notifications_type_check check (
    type in ('match_request','match_accepted','message','order_status','system')
  )
);

-- Normalized order items table (keep orders.items for backward compatibility)
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  unit_price numeric not null check (unit_price >= 0),
  quantity integer not null check (quantity > 0),
  line_total numeric generated always as (unit_price * quantity) stored,
  created_at timestamptz not null default now()
);

create index if not exists order_items_order_id_idx on public.order_items(order_id);

-- Backfill order_items from orders.items JSONB (idempotent per order)
insert into public.order_items (order_id, product_id, product_name, unit_price, quantity)
select
  o.id as order_id,
  nullif(item->>'product_id', '')::uuid as product_id,
  coalesce(nullif(item->>'name', ''), 'Unknown Item') as product_name,
  coalesce((item->>'price')::numeric, 0) as unit_price,
  greatest(coalesce((item->>'quantity')::int, 1), 1) as quantity
from public.orders o
cross join lateral jsonb_array_elements(o.items) item
where jsonb_typeof(o.items) = 'array'
  and not exists (
    select 1 from public.order_items oi where oi.order_id = o.id
  );

-- Strengthen/normalize existing status constraints (safe do-blocks)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'match_requests_status_check'
      and conrelid = 'public.match_requests'::regclass
  ) then
    alter table public.match_requests
      add constraint match_requests_status_check
      check (status in ('pending','matched','rejected'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'orders_status_check'
      and conrelid = 'public.orders'::regclass
  ) then
    alter table public.orders
      add constraint orders_status_check
      check (status in ('pending','confirmed','shipped','delivered','cancelled'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'messages_message_type_check'
      and conrelid = 'public.messages'::regclass
  ) then
    alter table public.messages
      add constraint messages_message_type_check
      check (message_type in ('text','image','system'));
  end if;
end $$;

-- Helpful indexes for scale
create index if not exists posts_created_at_idx on public.posts(created_at desc);
create index if not exists comments_post_created_at_idx on public.comments(post_id, created_at desc);
create index if not exists messages_thread_created_at_idx on public.messages(thread_id, created_at desc);
create index if not exists match_requests_receiver_status_idx on public.match_requests(receiver_pet_id, status, created_at desc);
create index if not exists products_category_created_at_idx on public.products(category, created_at desc);
create index if not exists orders_user_created_at_idx on public.orders(user_id, created_at desc);
create index if not exists pet_listings_status_created_at_idx on public.pet_listings(status, created_at desc);
create index if not exists notifications_user_unread_created_at_idx on public.notifications(user_id, is_read, created_at desc);

-- updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_chat_threads_updated_at on public.chat_threads;
create trigger set_chat_threads_updated_at
before update on public.chat_threads
for each row
execute function public.set_updated_at();

drop trigger if exists set_orders_updated_at on public.orders;
create trigger set_orders_updated_at
before update on public.orders
for each row
execute function public.set_updated_at();

drop trigger if exists set_pet_listings_updated_at on public.pet_listings;
create trigger set_pet_listings_updated_at
before update on public.pet_listings
for each row
execute function public.set_updated_at();

drop trigger if exists set_matches_updated_at on public.matches;
create trigger set_matches_updated_at
before update on public.matches
for each row
execute function public.set_updated_at();

-- Enable RLS on new tables
alter table public.pet_listings enable row level security;
alter table public.matches enable row level security;
alter table public.notifications enable row level security;
alter table public.order_items enable row level security;

-- RLS: pet_listings
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='pet_listings' AND policyname='Anyone can view active pet listings'
  ) THEN
    CREATE POLICY "Anyone can view active pet listings"
      ON public.pet_listings
      FOR SELECT
      USING (status = 'active');
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='pet_listings' AND policyname='Owners manage own pet listings'
  ) THEN
    CREATE POLICY "Owners manage own pet listings"
      ON public.pet_listings
      FOR ALL
      USING (
        auth.uid() = listed_by_user_id
        and auth.uid() = (select user_id from public.pets where id = pet_id)
      )
      WITH CHECK (
        auth.uid() = listed_by_user_id
        and auth.uid() = (select user_id from public.pets where id = pet_id)
      );
  END IF;
END $$;

-- RLS: matches
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='matches' AND policyname='Participants can view matches'
  ) THEN
    CREATE POLICY "Participants can view matches"
      ON public.matches
      FOR SELECT
      USING (
        auth.uid() = (select user_id from public.pets where id = pet_id_1)
        OR auth.uid() = (select user_id from public.pets where id = pet_id_2)
      );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='matches' AND policyname='Participants can create matches'
  ) THEN
    CREATE POLICY "Participants can create matches"
      ON public.matches
      FOR INSERT
      WITH CHECK (
        auth.uid() = (select user_id from public.pets where id = pet_id_1)
        OR auth.uid() = (select user_id from public.pets where id = pet_id_2)
      );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='matches' AND policyname='Participants can update own matches'
  ) THEN
    CREATE POLICY "Participants can update own matches"
      ON public.matches
      FOR UPDATE
      USING (
        auth.uid() = (select user_id from public.pets where id = pet_id_1)
        OR auth.uid() = (select user_id from public.pets where id = pet_id_2)
      )
      WITH CHECK (
        auth.uid() = (select user_id from public.pets where id = pet_id_1)
        OR auth.uid() = (select user_id from public.pets where id = pet_id_2)
      );
  END IF;
END $$;

-- RLS: notifications
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='notifications' AND policyname='Users can view own notifications'
  ) THEN
    CREATE POLICY "Users can view own notifications"
      ON public.notifications
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='notifications' AND policyname='Users can update own notifications'
  ) THEN
    CREATE POLICY "Users can update own notifications"
      ON public.notifications
      FOR UPDATE
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='notifications' AND policyname='Users can insert own notifications'
  ) THEN
    CREATE POLICY "Users can insert own notifications"
      ON public.notifications
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- RLS: order_items follows parent orders ownership
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='order_items' AND policyname='Users can view own order items'
  ) THEN
    CREATE POLICY "Users can view own order items"
      ON public.order_items
      FOR SELECT
      USING (
        auth.uid() = (select user_id from public.orders where id = order_id)
      );
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='order_items' AND policyname='Users can insert own order items'
  ) THEN
    CREATE POLICY "Users can insert own order items"
      ON public.order_items
      FOR INSERT
      WITH CHECK (
        auth.uid() = (select user_id from public.orders where id = order_id)
      );
  END IF;
END $$;

commit;
