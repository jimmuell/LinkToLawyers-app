/*
  Migration: Create quotes table
  Purpose: Store attorney quotes/proposals for client requests
  Tables: quotes
  Features: One quote per attorney per request with acceptance tracking
*/

-- Create enum for quote status
create type public.quote_status as enum ('draft', 'submitted', 'under_review', 'accepted', 'declined', 'withdrawn', 'expired');

-- Create quotes table
create table public.quotes (
  id bigint generated always as identity primary key,
  request_id bigint references public.requests(id) on delete cascade not null,
  attorney_id uuid references public.profiles(id) on delete cascade not null,
  proposal_text text not null,
  fee_amount numeric(10,2),
  fee_structure text, -- hourly, fixed, contingency, etc.
  estimated_timeline text,
  terms_and_conditions text,
  status public.quote_status default 'draft' not null,
  admin_notes text, -- Internal notes for admins
  metadata jsonb default '{}', -- Flexible storage for additional quote data
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  submitted_at timestamptz,
  accepted_at timestamptz,
  declined_at timestamptz,
  expires_at timestamptz,
  
  -- Ensure one quote per attorney per request
  constraint quotes_attorney_request_unique unique (request_id, attorney_id)
);

-- Add table comment
comment on table public.quotes is 'Attorney quotes and proposals for client requests';

-- Create indexes for better performance
create index quotes_request_id_idx on public.quotes (request_id);
create index quotes_attorney_id_idx on public.quotes (attorney_id);
create index quotes_status_idx on public.quotes (status);
create index quotes_created_at_idx on public.quotes (created_at desc);
create index quotes_submitted_at_idx on public.quotes (submitted_at desc);
create index quotes_expires_at_idx on public.quotes (expires_at);

-- Enable Row Level Security
alter table public.quotes enable row level security;

-- RLS Policies for quotes table

-- Select policy: Attorneys can view their own quotes
create policy "Attorneys can view their own quotes" on public.quotes
for select
to authenticated
using ( attorney_id = auth.uid() );

-- Select policy: Clients can view quotes for their requests
create policy "Clients can view quotes for their requests" on public.quotes
for select
to authenticated
using ( 
  exists (
    select 1 from public.requests 
    where id = request_id and client_id = auth.uid()
  )
);

-- Select policy: Admins can view all quotes
create policy "Admins can view all quotes" on public.quotes
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Insert policy: Verified attorneys can create quotes for open requests
create policy "Attorneys can create quotes" on public.quotes
for insert
to authenticated
with check ( 
  attorney_id = auth.uid() and
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'attorney' and verification_status = 'verified'
  ) and
  exists (
    select 1 from public.requests 
    where id = request_id and status = 'open_for_quotes'
  )
);

-- Update policy: Attorneys can update their own draft quotes
create policy "Attorneys can update their draft quotes" on public.quotes
for update
to authenticated
using ( 
  attorney_id = auth.uid() and 
  status = 'draft'
)
with check ( 
  attorney_id = auth.uid() and
  status in ('draft', 'submitted')
);

-- Update policy: Clients can accept/decline quotes for their requests
create policy "Clients can accept or decline quotes" on public.quotes
for update
to authenticated
using ( 
  exists (
    select 1 from public.requests 
    where id = request_id and client_id = auth.uid()
  ) and
  status = 'submitted'
)
with check ( 
  exists (
    select 1 from public.requests 
    where id = request_id and client_id = auth.uid()
  ) and
  status in ('accepted', 'declined')
);

-- Update policy: Admins can update all quotes
create policy "Admins can update all quotes" on public.quotes
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

-- Delete policy: Attorneys can delete their own draft quotes
create policy "Attorneys can delete draft quotes" on public.quotes
for delete
to authenticated
using ( 
  attorney_id = auth.uid() and 
  status = 'draft'
);

-- Delete policy: Admins can delete any quote
create policy "Admins can delete quotes" on public.quotes
for delete
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Trigger to automatically update updated_at
create trigger quotes_updated_at
  before update on public.quotes
  for each row
  execute function public.handle_updated_at();

-- Function to handle quote status changes and ensure only one acceptance per request
create or replace function public.handle_quote_status_change()
returns trigger as $$
begin
  -- Set submitted_at when status changes to submitted
  if old.status != 'submitted' and new.status = 'submitted' then
    new.submitted_at = now();
  end if;
  
  -- Set accepted_at when status changes to accepted
  if old.status != 'accepted' and new.status = 'accepted' then
    new.accepted_at = now();
    
    -- Ensure only one quote can be accepted per request
    -- Decline all other quotes for this request
    update public.quotes 
    set status = 'declined', declined_at = now()
    where request_id = new.request_id 
      and id != new.id 
      and status = 'submitted';
      
    -- Update request status to matched
    update public.requests 
    set status = 'matched'
    where id = new.request_id;
  end if;
  
  -- Set declined_at when status changes to declined
  if old.status != 'declined' and new.status = 'declined' then
    new.declined_at = now();
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger for quote status change handling
create trigger quotes_status_change_handler
  before update on public.quotes
  for each row
  execute function public.handle_quote_status_change();

-- Function to set default expiration date
create or replace function public.set_quote_expiration()
returns trigger as $$
begin
  -- Set expiration to 30 days from submission if not already set
  if new.status = 'submitted' and new.expires_at is null then
    new.expires_at = now() + interval '30 days';
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger to set quote expiration
create trigger quotes_expiration_handler
  before insert or update on public.quotes
  for each row
  execute function public.set_quote_expiration();
