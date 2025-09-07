/*
  Migration: Create consultations table
  Purpose: Store scheduled consultations between clients and attorneys
  Tables: consultations
  Features: Appointment scheduling with status tracking and reminders
*/

-- Create enum for consultation status
create type public.consultation_status as enum (
  'requested',
  'confirmed',
  'rescheduled',
  'completed',
  'cancelled',
  'no_show'
);

-- Create enum for consultation types
create type public.consultation_type as enum (
  'initial_consultation',
  'follow_up',
  'case_review',
  'document_review',
  'strategy_session',
  'other'
);

-- Create consultations table
create table public.consultations (
  id bigint generated always as identity primary key,
  quote_id bigint references public.quotes(id) on delete cascade not null,
  client_id uuid references public.profiles(id) on delete cascade not null,
  attorney_id uuid references public.profiles(id) on delete cascade not null,
  consultation_type public.consultation_type default 'initial_consultation',
  title text not null,
  description text,
  scheduled_date date not null,
  scheduled_time time not null,
  duration_minutes integer default 60 not null,
  timezone text default 'UTC' not null,
  location text, -- Physical address or "Virtual"
  meeting_url text, -- For virtual meetings
  status public.consultation_status default 'requested' not null,
  client_notes text,
  attorney_notes text,
  admin_notes text,
  reminder_sent boolean default false,
  metadata jsonb default '{}', -- Additional consultation data
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  confirmed_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz
);

-- Add table comment
comment on table public.consultations is 'Scheduled consultations between clients and attorneys';

-- Create indexes for better performance
create index consultations_quote_id_idx on public.consultations (quote_id);
create index consultations_client_id_idx on public.consultations (client_id);
create index consultations_attorney_id_idx on public.consultations (attorney_id);
create index consultations_status_idx on public.consultations (status);
create index consultations_scheduled_date_idx on public.consultations (scheduled_date);
create index consultations_created_at_idx on public.consultations (created_at desc);
create index consultations_reminder_sent_idx on public.consultations (reminder_sent, scheduled_date);

-- Enable Row Level Security
alter table public.consultations enable row level security;

-- RLS Policies for consultations table

-- Select policy: Clients can view their consultations
create policy "Clients can view their consultations" on public.consultations
for select
to authenticated
using ( client_id = auth.uid() );

-- Select policy: Attorneys can view their consultations
create policy "Attorneys can view their consultations" on public.consultations
for select
to authenticated
using ( attorney_id = auth.uid() );

-- Select policy: Admins can view all consultations
create policy "Admins can view all consultations" on public.consultations
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Insert policy: Clients can schedule consultations for accepted quotes
create policy "Clients can schedule consultations" on public.consultations
for insert
to authenticated
with check ( 
  client_id = auth.uid() and
  exists (
    select 1 from public.quotes 
    where id = quote_id and status = 'accepted' and
    exists (
      select 1 from public.requests 
      where id = quotes.request_id and client_id = auth.uid()
    )
  )
);

-- Insert policy: Attorneys can schedule consultations for their accepted quotes
create policy "Attorneys can schedule consultations" on public.consultations
for insert
to authenticated
with check ( 
  attorney_id = auth.uid() and
  exists (
    select 1 from public.quotes 
    where id = quote_id and attorney_id = auth.uid() and status = 'accepted'
  )
);

-- Update policy: Clients can update their consultation details
create policy "Clients can update their consultations" on public.consultations
for update
to authenticated
using ( client_id = auth.uid() )
with check ( 
  client_id = auth.uid() and
  attorney_id = old.attorney_id and
  quote_id = old.quote_id
);

-- Update policy: Attorneys can update their consultation details
create policy "Attorneys can update their consultations" on public.consultations
for update
to authenticated
using ( attorney_id = auth.uid() )
with check ( 
  attorney_id = auth.uid() and
  client_id = old.client_id and
  quote_id = old.quote_id
);

-- Update policy: Admins can update all consultations
create policy "Admins can update all consultations" on public.consultations
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

-- Delete policy: Clients can cancel their consultations
create policy "Clients can cancel consultations" on public.consultations
for delete
to authenticated
using ( 
  client_id = auth.uid() and
  status in ('requested', 'confirmed')
);

-- Delete policy: Attorneys can cancel their consultations
create policy "Attorneys can cancel consultations" on public.consultations
for delete
to authenticated
using ( 
  attorney_id = auth.uid() and
  status in ('requested', 'confirmed')
);

-- Delete policy: Admins can delete any consultation
create policy "Admins can delete consultations" on public.consultations
for delete
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Trigger to automatically update updated_at
create trigger consultations_updated_at
  before update on public.consultations
  for each row
  execute function public.handle_updated_at();

-- Function to handle consultation status changes
create or replace function public.handle_consultation_status_change()
returns trigger as $$
begin
  -- Set confirmed_at when status changes to confirmed
  if old.status != 'confirmed' and new.status = 'confirmed' then
    new.confirmed_at = now();
  end if;
  
  -- Set completed_at when status changes to completed
  if old.status != 'completed' and new.status = 'completed' then
    new.completed_at = now();
  end if;
  
  -- Set cancelled_at when status changes to cancelled
  if old.status != 'cancelled' and new.status = 'cancelled' then
    new.cancelled_at = now();
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger for consultation status change handling
create trigger consultations_status_change_handler
  before update on public.consultations
  for each row
  execute function public.handle_consultation_status_change();

-- Function to validate consultation participants
create or replace function public.validate_consultation_participants()
returns trigger as $$
begin
  -- Ensure consultation participants match the quote
  if not exists (
    select 1 from public.quotes q
    join public.requests r on q.request_id = r.id
    where q.id = new.quote_id and
    q.attorney_id = new.attorney_id and
    r.client_id = new.client_id
  ) then
    raise exception 'Consultation participants must match the quote participants';
  end if;
  
  -- Ensure consultation is not scheduled in the past
  if (new.scheduled_date || ' ' || new.scheduled_time)::timestamp < now() then
    raise exception 'Cannot schedule consultation in the past';
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger to validate consultation participants and timing
create trigger consultations_participants_validator
  before insert on public.consultations
  for each row
  execute function public.validate_consultation_participants();
