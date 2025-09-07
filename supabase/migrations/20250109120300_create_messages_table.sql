/*
  Migration: Create messages table
  Purpose: Store secure messages between clients and attorneys
  Tables: messages
  Features: Secure communication with read receipts and attachments
*/

-- Create enum for message types
create type public.message_type as enum ('text', 'system', 'document_share', 'appointment_request');

-- Create messages table
create table public.messages (
  id bigint generated always as identity primary key,
  quote_id bigint references public.quotes(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  recipient_id uuid references public.profiles(id) on delete cascade not null,
  message_type public.message_type default 'text' not null,
  subject text,
  message_text text not null,
  is_read boolean default false not null,
  read_at timestamptz,
  metadata jsonb default '{}', -- For storing additional message data like attachments
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Add table comment
comment on table public.messages is 'Secure messages between clients and attorneys within quote conversations';

-- Create indexes for better performance
create index messages_quote_id_idx on public.messages (quote_id);
create index messages_sender_id_idx on public.messages (sender_id);
create index messages_recipient_id_idx on public.messages (recipient_id);
create index messages_is_read_idx on public.messages (is_read);
create index messages_created_at_idx on public.messages (created_at desc);
create index messages_message_type_idx on public.messages (message_type);

-- Enable Row Level Security
alter table public.messages enable row level security;

-- RLS Policies for messages table

-- Select policy: Users can view messages they sent or received
create policy "Users can view their own messages" on public.messages
for select
to authenticated
using ( 
  sender_id = auth.uid() or 
  recipient_id = auth.uid() 
);

-- Select policy: Admins can view all messages
create policy "Admins can view all messages" on public.messages
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Insert policy: Users can send messages in quotes they're part of
create policy "Users can send messages in their quotes" on public.messages
for insert
to authenticated
with check ( 
  sender_id = auth.uid() and
  exists (
    select 1 from public.quotes 
    where id = quote_id and 
    (attorney_id = auth.uid() or 
     exists (
       select 1 from public.requests 
       where id = quotes.request_id and client_id = auth.uid()
     ))
  )
);

-- Update policy: Recipients can mark messages as read
create policy "Recipients can mark messages as read" on public.messages
for update
to authenticated
using ( recipient_id = auth.uid() )
with check ( 
  recipient_id = auth.uid() and
  -- Only allow updating read status and read_at
  sender_id = old.sender_id and
  quote_id = old.quote_id and
  message_text = old.message_text and
  message_type = old.message_type
);

-- Update policy: Admins can update all messages
create policy "Admins can update all messages" on public.messages
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

-- Delete policy: Senders can delete their own messages within 5 minutes
create policy "Senders can delete recent messages" on public.messages
for delete
to authenticated
using ( 
  sender_id = auth.uid() and
  created_at > now() - interval '5 minutes'
);

-- Delete policy: Admins can delete any message
create policy "Admins can delete messages" on public.messages
for delete
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Trigger to automatically update updated_at
create trigger messages_updated_at
  before update on public.messages
  for each row
  execute function public.handle_updated_at();

-- Function to handle message read status
create or replace function public.handle_message_read()
returns trigger as $$
begin
  -- Set read_at when is_read changes from false to true
  if old.is_read = false and new.is_read = true then
    new.read_at = now();
  end if;
  
  -- Clear read_at if is_read changes from true to false
  if old.is_read = true and new.is_read = false then
    new.read_at = null;
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger for message read status handling
create trigger messages_read_handler
  before update on public.messages
  for each row
  execute function public.handle_message_read();

-- Function to validate message participants
create or replace function public.validate_message_participants()
returns trigger as $$
begin
  -- Ensure sender and recipient are part of the quote
  if not exists (
    select 1 from public.quotes q
    join public.requests r on q.request_id = r.id
    where q.id = new.quote_id and
    (
      (new.sender_id = q.attorney_id and new.recipient_id = r.client_id) or
      (new.sender_id = r.client_id and new.recipient_id = q.attorney_id)
    )
  ) then
    raise exception 'Message participants must be the client and attorney from the quote';
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger to validate message participants
create trigger messages_participants_validator
  before insert on public.messages
  for each row
  execute function public.validate_message_participants();
