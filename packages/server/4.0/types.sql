-- Custom types
create type public.project_type as enum ('idea', 'note', 'story');
create type public.app_permission as enum (
  'projects.delete', 
  'projects.edit', 
  'folders.delete', 
  'folders.edit'
);
create type public.user_status as enum ('online', 'offline');
create type public.app_role as enum ('owner', 'guest');


