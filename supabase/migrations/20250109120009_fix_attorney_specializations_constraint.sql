/*
  Migration: Fix attorney specializations constraint
  Purpose: Update handle_new_user to satisfy attorney_fields_check constraint
  Updates: Add specializations field for attorney roles to meet constraint requirements
*/

-- Update the handle_new_user function to handle attorney specializations constraint
create or replace function public.handle_new_user()
returns trigger as $$
declare
    user_role_value text;
    parsed_role public.user_role;
begin
    -- Log the incoming data for debugging
    raise log 'handle_new_user triggered for user: %', new.id;
    raise log 'raw_user_meta_data: %', new.raw_user_meta_data;
    
    -- Extract and validate the role
    user_role_value := coalesce(new.raw_user_meta_data->>'role', 'client');
    raise log 'extracted role value: %', user_role_value;
    
    -- Cast to enum with error handling
    begin
        parsed_role := user_role_value::public.user_role;
    exception when others then
        raise log 'Error casting role, using default client role. Error: %', SQLERRM;
        parsed_role := 'client'::public.user_role;
    end;
    
    raise log 'final parsed role: %', parsed_role;
    
    -- Insert the profile with attorney specializations if needed
    insert into public.profiles (
        id, 
        role,
        first_name, 
        last_name, 
        display_name,
        specializations
    )
    values (
        new.id, 
        parsed_role,
        coalesce(new.raw_user_meta_data->>'first_name', ''),
        coalesce(new.raw_user_meta_data->>'last_name', ''),
        coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'full_name', new.email),
        -- Provide default specializations for attorneys to satisfy constraint
        case 
            when parsed_role = 'attorney' then array['General Practice']::text[]
            else null
        end
    );
    
    raise log 'Profile created successfully for user: %', new.id;
    return new;
    
exception when others then
    raise log 'Error in handle_new_user: %', SQLERRM;
    raise;
end;
$$ language plpgsql security definer;
