begin;

-- ---------------------------------------------------------------------------
-- Notifications event functions (SECURITY DEFINER so system inserts are allowed)
-- ---------------------------------------------------------------------------
create or replace function public.notify_on_match_accepted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  sender_user_id uuid;
  receiver_user_id uuid;
  sender_name text;
  receiver_name text;
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;

  if new.status = 'matched' and old.status is distinct from new.status then
    select p.user_id, p.name into sender_user_id, sender_name
    from public.pets p
    where p.id = new.sender_pet_id;

    select p.user_id, p.name into receiver_user_id, receiver_name
    from public.pets p
    where p.id = new.receiver_pet_id;

    -- Notify sender that receiver accepted.
    if sender_user_id is not null then
      insert into public.notifications (
        user_id,
        actor_pet_id,
        type,
        title,
        body,
        entity_type,
        entity_id
      )
      values (
        sender_user_id,
        new.receiver_pet_id,
        'match_accepted',
        'It''s a match! 🎉',
        coalesce(receiver_name, 'A pet') || ' accepted your match request.',
        'match_request',
        new.id
      );
    end if;

    -- Notify receiver as confirmation.
    if receiver_user_id is not null then
      insert into public.notifications (
        user_id,
        actor_pet_id,
        type,
        title,
        body,
        entity_type,
        entity_id
      )
      values (
        receiver_user_id,
        new.sender_pet_id,
        'match_accepted',
        'Match confirmed ✅',
        'You are now matched with ' || coalesce(sender_name, 'a pet') || '.',
        'match_request',
        new.id
      );
    end if;
  end if;

  return new;
end;
$$;

create or replace function public.notify_on_new_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  pet1 uuid;
  pet2 uuid;
  recipient_pet_id uuid;
  recipient_user_id uuid;
  sender_name text;
begin
  if tg_op <> 'INSERT' then
    return new;
  end if;

  select ct.pet_id_1, ct.pet_id_2
    into pet1, pet2
  from public.chat_threads ct
  where ct.id = new.thread_id;

  if pet1 is null and pet2 is null then
    return new;
  end if;

  recipient_pet_id := case
    when new.sender_pet_id = pet1 then pet2
    else pet1
  end;

  select p.user_id into recipient_user_id
  from public.pets p
  where p.id = recipient_pet_id;

  select p.name into sender_name
  from public.pets p
  where p.id = new.sender_pet_id;

  if recipient_user_id is not null then
    insert into public.notifications (
      user_id,
      actor_pet_id,
      type,
      title,
      body,
      entity_type,
      entity_id
    )
    values (
      recipient_user_id,
      new.sender_pet_id,
      'message',
      coalesce(sender_name, 'New message'),
      coalesce(left(new.text, 120), 'You received a new message.'),
      'message',
      new.id
    );
  end if;

  return new;
end;
$$;

create or replace function public.notify_on_order_status_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;

  if new.status is distinct from old.status and new.status <> 'pending' then
    insert into public.notifications (
      user_id,
      actor_pet_id,
      type,
      title,
      body,
      entity_type,
      entity_id
    )
    values (
      new.user_id,
      null,
      'order_status',
      'Order status updated',
      'Your order is now: ' || new.status,
      'order',
      new.id
    );
  end if;

  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
drop trigger if exists trg_notify_match_accepted on public.match_requests;
create trigger trg_notify_match_accepted
after update on public.match_requests
for each row
execute function public.notify_on_match_accepted();

drop trigger if exists trg_notify_new_message on public.messages;
create trigger trg_notify_new_message
after insert on public.messages
for each row
execute function public.notify_on_new_message();

drop trigger if exists trg_notify_order_status_change on public.orders;
create trigger trg_notify_order_status_change
after update on public.orders
for each row
execute function public.notify_on_order_status_change();

commit;
