-- Add payment fields to orders for marketplace checkout.
-- Used by Stripe PaymentIntent flow.

alter table public.orders
  add column if not exists payment_provider text,
  add column if not exists payment_intent_id text,
  add column if not exists payment_status text;

-- Optional: lightweight index for support/debug lookups.
create index if not exists idx_orders_payment_intent_id on public.orders (payment_intent_id);

