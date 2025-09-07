/*
  Migration: Create new user trigger
  Purpose: Create the missing trigger that calls handle_new_user function when users sign up
  Updates: Add trigger on auth.users table
*/

-- Drop existing trigger if it exists and recreate it
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger to automatically create profile when user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
