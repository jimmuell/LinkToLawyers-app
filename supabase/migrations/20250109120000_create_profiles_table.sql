/*
  Migration: Create profiles table
  Purpose: Store user profile information for clients, attorneys, and admins
  Tables: profiles
  Features: Role-based user profiles with flexible JSONB data storage
*/

-- Create enum for user roles
create type public.user_role as enum ('client', 'attorney', 'admin');

-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  role public.user_role not null default 'client',
  email text not null,
  first_name text,
  last_name text,
  phone text,
  location text,
  jurisdiction text, -- For attorneys, their licensed jurisdiction
  verification_status text default 'pending', -- pending, verified, rejected
  specializations text[], -- Array of legal specializations for attorneys
  bio text,
  profile_details jsonb default '{}', -- Flexible storage for role-specific data
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Add table comment
comment on table public.profiles is 'User profiles for clients, attorneys, and admins with role-based information';

-- Create indexes for better performance
create index profiles_role_idx on public.profiles (role);
create index profiles_email_idx on public.profiles (email);
create index profiles_verification_status_idx on public.profiles (verification_status);
create index profiles_jurisdiction_idx on public.profiles (jurisdiction);
create index profiles_specializations_idx on public.profiles using gin (specializations);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- RLS Policies for profiles table

-- Select policy: Users can view their own profile and verified attorneys are public
create policy "Users can view their own profile" on public.profiles
for select
to authenticated
using ( auth.uid() = id );

create policy "Verified attorneys are publicly viewable" on public.profiles
for select
to authenticated, anon
using ( 
  role = 'attorney' and 
  verification_status = 'verified' 
);

-- Insert policy: Users can create their own profile
create policy "Users can create their own profile" on public.profiles
for insert
to authenticated
with check ( auth.uid() = id );

-- Update policy: Users can update their own profile
create policy "Users can update their own profile" on public.profiles
for update
to authenticated
using ( auth.uid() = id )
with check ( auth.uid() = id );

-- Delete policy: Users can delete their own profile
create policy "Users can delete their own profile" on public.profiles
for delete
to authenticated
using ( auth.uid() = id );

-- Admin policies: Admins can manage all profiles
create policy "Admins can view all profiles" on public.profiles
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

create policy "Admins can update all profiles" on public.profiles
for update
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
)
with check ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Function to automatically update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Trigger to automatically update updated_at
create trigger profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.handle_updated_at();

-- Function to create profile on auth signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'client');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile when user signs up
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
