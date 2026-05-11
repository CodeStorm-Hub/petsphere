create or replace function public.sync_community_group_member_count()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_group_id uuid;
begin
  v_group_id := coalesce(new.group_id, old.group_id);

  update public.community_groups
  set member_count = (
    select count(*)::int
    from public.community_group_members
    where group_id = v_group_id
  )
  where id = v_group_id;

  return coalesce(new, old);
end;
$$;

revoke all on function public.sync_community_group_member_count() from public;
revoke all on function public.sync_community_group_member_count() from anon;
revoke all on function public.sync_community_group_member_count() from authenticated;

drop trigger if exists trg_sync_community_group_member_count
  on public.community_group_members;

create trigger trg_sync_community_group_member_count
after insert or delete on public.community_group_members
for each row
execute function public.sync_community_group_member_count();

create or replace function public.increment_group_member_count(p_group_id uuid)
returns void
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
begin
  update public.community_groups
  set member_count = (
    select count(*)::int
    from public.community_group_members
    where group_id = p_group_id
  )
  where id = p_group_id;
end;
$$;

revoke all on function public.increment_group_member_count(uuid) from public;
revoke all on function public.increment_group_member_count(uuid) from anon;
revoke all on function public.increment_group_member_count(uuid) from authenticated;
grant execute on function public.increment_group_member_count(uuid) to service_role;

drop policy if exists "Users can join groups" on public.community_group_members;
create policy "Users can join groups"
on public.community_group_members
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Members can view their own membership" on public.community_group_members;
create policy "Members can view their own membership"
on public.community_group_members
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can leave groups" on public.community_group_members;
create policy "Users can leave groups"
on public.community_group_members
for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Authenticated users can create groups" on public.community_groups;
create policy "Authenticated users can create groups"
on public.community_groups
for insert
to authenticated
with check ((select auth.uid()) = owner_id);
