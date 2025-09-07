/*
  Migration: Fix user_role schema reference
  Purpose: Explicitly reference public.user_role to avoid schema issues
  Updates: handle_new_user function with proper schema qualification
*/

-- Update the handle_new_user function with explicit schema references
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
    coalesce((new.raw_user_meta_data->>'role')::public.user_role, 'client'::public.user_role),
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name', new.email)
  );
  return new;
end;
$$ language plpgsql security definer;
