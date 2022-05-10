
-- authorize with role-based access control (RBAC)
create function public.authorize(
  requested_permission app_permission,
  user_id uuid
)
returns boolean as
$$
  declare
    bind_permissions int;
  begin
    select
      count(*)
    from public.role_permissions
    inner join public.user_roles on role_permissions.role = user_roles.role
    where
      role_permissions.permission = authorize.requested_permission and
      user_roles.user_id = authorize.user_id
    into bind_permissions;

    return bind_permissions > 0;
  end;
$$
language plpgsql security definer;


-- Secure the tables
alter table public.users
  enable row level security;
alter table public.folders
  enable row level security;
alter table public.projects
  enable row level security;
alter table public.user_roles
  enable row level security;
alter table public.role_permissions
  enable row level security;


-- USERS
create policy "Allow individual read access" on public.users
  for select using (auth.uid() = id);
create policy "Allow individual insert access" on public.users
  for insert with check (auth.uid() = id);
create policy "Allow individual update access" on public.users
  for update using (auth.uid() = id);

-- FOLDERS
create policy "Allow individual read access" on public.folders
  for select using (auth.uid() = owner_id);
create policy "Allow individual insert access" on public.folders
  for insert with check (auth.uid() = owner_id);
create policy "Allow individual delete access" on public.folders
  for delete using (auth.uid() = owner_id);
create policy "Allow authorized delete access" on public.folders
  for delete using (authorize('folders.delete', auth.uid()));

-- PROJECTS
create policy "Allow individual read access" on public.projects
  for select using (auth.uid() = user_id);
create policy "Allow individual insert access" on public.projects
  for insert with check (auth.uid() = user_id);
create policy "Allow individual update access" on public.projects
  for update using (auth.uid() = user_id);
create policy "Allow individual delete access" on public.projects
  for delete using (auth.uid() = user_id);
create policy "Allow authorized delete access" on public.projects
  for delete using (authorize('projects.delete', auth.uid()));

-- USER ROLES
create policy "Allow individual read access" on public.user_roles
  for select using (auth.uid() = user_id);


-- Send "previous data" on change
alter table public.users
  replica identity full;
alter table public.user_roles
  replica identity full;
alter table public.role_permissions
  replica identity full;

alter table public.folders
  replica identity full;

alter table public.projects
  replica identity full;
alter table public.idea_project_questions
  replica identity full;
alter table public.idea_project_answers
  replica identity full;


-- inserts a row into public.users and assigns roles
create function public.handle_new_user()
returns trigger as
$$
  declare is_admin boolean;
  begin
    insert into public.users (id, username)
    values (new.id, new.email);

    select count(*) = 1 from auth.users into is_admin;

    if position('+supaadmin@' in new.email) > 0 then
      insert into public.user_roles (user_id, role) values (new.id, 'owner');
    elsif position('+supamod@' in new.email) > 0 then
      insert into public.user_roles (user_id, role) values (new.id, 'guest');
    end if;

    return new;
  end;
$$ language plpgsql security definer;

-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


/**
 * REALTIME SUBSCRIPTIONS
 * Only allow realtime listening on public tables.
 */

begin;
  -- remove the realtime publication
  drop publication if exists supabase_realtime;

  -- re-create the publication but don't enable it for any tables
  create publication supabase_realtime;
commit;

-- add tables to the publication
alter publication supabase_realtime add table public.folders;
alter publication supabase_realtime add table public.projects;
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.idea_project_answers;
alter publication supabase_realtime add table public.idea_project_questions
