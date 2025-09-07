/*
  Migration: Update profile creation with user metadata
  Purpose: Enhance the handle_new_user function to populate profile with name and phone from user metadata
  Updates: Update handle_new_user function to use user metadata
*/

-- Update the handle_new_user function to populate profile with user metadata
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
