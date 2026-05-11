-- Persist shipping details captured during marketplace checkout.

alter table public.orders
  add column if not exists shipping_name text,
  add column if not exists shipping_address text,
  add column if not exists shipping_city text,
  add column if not exists shipping_state text,
  add column if not exists shipping_zip text;
