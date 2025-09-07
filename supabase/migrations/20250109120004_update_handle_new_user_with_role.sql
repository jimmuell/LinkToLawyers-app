/*
  Migration: Update handle_new_user function with role support
  Purpose: Update the trigger to properly handle role selection from sign-up form
  Updates: handle_new_user function to use role from user metadata
*/

-- Update the handle_new_user function to handle role from metadata
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (
    id, 
    role,
    first_name, 
    last_name, 
    display_name,
    verification_status
  )
  values (
    new.id, 
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'client'::user_role),
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name', new.email),
    case 
      when coalesce(new.raw_user_meta_data->>'role', 'client') = 'attorney' 
      then 'pending' 
      else 'verified' 
    end
  );
  return new;
end;
$$ language plpgsql security definer;
