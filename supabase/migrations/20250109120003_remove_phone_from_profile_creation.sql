/*
  Migration: Remove phone from profile creation
  Purpose: Update handle_new_user function to remove phone field handling since we removed phone from sign-up
  Updates: handle_new_user function
*/

-- Update the handle_new_user function to remove phone handling
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
    'client', -- Default role, can be changed later
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name', new.email)
  );
  return new;
end;
$$ language plpgsql security definer;
