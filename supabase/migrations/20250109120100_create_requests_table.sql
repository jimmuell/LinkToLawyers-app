/*
  Migration: Create requests table
  Purpose: Store client legal service requests
  Tables: requests
  Features: Client submissions with categorization and status tracking
*/

-- Create enum for request status
create type public.request_status as enum ('draft', 'submitted', 'under_review', 'open_for_quotes', 'matched', 'closed', 'cancelled');

-- Create enum for case types
create type public.case_type as enum (
  'personal_injury',
  'family_law',
  'criminal_defense',
  'business_law',
  'real_estate',
  'immigration',
  'employment_law',
  'estate_planning',
  'bankruptcy',
  'intellectual_property',
  'tax_law',
  'other'
);

-- Create enum for urgency levels
create type public.urgency_level as enum ('low', 'medium', 'high', 'urgent');

-- Create requests table
create table public.requests (
  id bigint generated always as identity primary key,
  client_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  description text not null,
  case_type public.case_type not null,
  urgency_level public.urgency_level default 'medium',
  budget_min numeric(10,2),
  budget_max numeric(10,2),
  location text,
  jurisdiction text,
  preferred_language text default 'english',
  status public.request_status default 'draft' not null,
  admin_notes text, -- Internal notes for admins
  metadata jsonb default '{}', -- Flexible storage for additional request data
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  submitted_at timestamptz,
  closed_at timestamptz
);

-- Add table comment
comment on table public.requests is 'Legal service requests submitted by clients';

-- Create indexes for better performance
create index requests_client_id_idx on public.requests (client_id);
create index requests_status_idx on public.requests (status);
create index requests_case_type_idx on public.requests (case_type);
create index requests_urgency_level_idx on public.requests (urgency_level);
create index requests_jurisdiction_idx on public.requests (jurisdiction);
create index requests_created_at_idx on public.requests (created_at desc);
create index requests_submitted_at_idx on public.requests (submitted_at desc);

-- Enable Row Level Security
alter table public.requests enable row level security;

-- RLS Policies for requests table

-- Select policy: Clients can view their own requests
create policy "Clients can view their own requests" on public.requests
for select
to authenticated
using ( client_id = auth.uid() );

-- Select policy: Attorneys can view open requests they might quote on
create policy "Attorneys can view open requests" on public.requests
for select
to authenticated
using ( 
  status in ('open_for_quotes', 'matched') and
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'attorney' and verification_status = 'verified'
  )
);

-- Select policy: Admins can view all requests
create policy "Admins can view all requests" on public.requests
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Insert policy: Clients can create their own requests
create policy "Clients can create requests" on public.requests
for insert
to authenticated
with check ( 
  client_id = auth.uid() and
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'client'
  )
);

-- Update policy: Clients can update their own draft requests
create policy "Clients can update their draft requests" on public.requests
for update
to authenticated
using ( 
  client_id = auth.uid() and 
  status = 'draft'
)
with check ( 
  client_id = auth.uid() and
  status = 'draft'
);

-- Update policy: Admins can update all requests
create policy "Admins can update all requests" on public.requests
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

-- Delete policy: Clients can delete their own draft requests
create policy "Clients can delete draft requests" on public.requests
for delete
to authenticated
using ( 
  client_id = auth.uid() and 
  status = 'draft'
);

-- Delete policy: Admins can delete any request
create policy "Admins can delete requests" on public.requests
for delete
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Trigger to automatically update updated_at
create trigger requests_updated_at
  before update on public.requests
  for each row
  execute function public.handle_updated_at();

-- Function to update submitted_at when status changes to submitted
create or replace function public.handle_request_submission()
returns trigger as $$
begin
  -- Set submitted_at when status changes to submitted
  if old.status != 'submitted' and new.status = 'submitted' then
    new.submitted_at = now();
  end if;
  
  -- Set closed_at when status changes to closed or cancelled
  if old.status not in ('closed', 'cancelled') and new.status in ('closed', 'cancelled') then
    new.closed_at = now();
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger for request submission handling
create trigger requests_submission_handler
  before update on public.requests
  for each row
  execute function public.handle_request_submission();
