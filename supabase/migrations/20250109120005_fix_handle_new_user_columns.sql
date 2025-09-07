/*
  Migration: Fix handle_new_user function columns
  Purpose: Remove reference to non-existent verification_status column
  Updates: handle_new_user function to match actual table schema
*/

-- Update the handle_new_user function to match actual table columns
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (
    id, 
    role,
    first_name, 
    last_name, 
    display_name
  )
  values (
    new.id, 
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'client'::user_role),
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name', new.email)
  );
  return new;
end;
$$ language plpgsql security definer;
