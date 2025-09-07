/*
  Migration: Create documents table
  Purpose: Store document references and metadata for file uploads
  Tables: documents
  Features: Secure document sharing with access control and metadata
*/

-- Create enum for document types
create type public.document_type as enum (
  'contract',
  'evidence',
  'identification',
  'financial_statement',
  'legal_document',
  'correspondence',
  'image',
  'other'
);

-- Create enum for document access levels
create type public.document_access_level as enum ('private', 'shared', 'public');

-- Create documents table
create table public.documents (
  id bigint generated always as identity primary key,
  quote_id bigint references public.quotes(id) on delete cascade,
  request_id bigint references public.requests(id) on delete cascade,
  uploaded_by uuid references public.profiles(id) on delete cascade not null,
  file_name text not null,
  file_size bigint not null,
  file_type text not null,
  document_type public.document_type default 'other',
  access_level public.document_access_level default 'private' not null,
  storage_path text not null, -- Path in Supabase Storage
  storage_bucket text default 'documents' not null,
  description text,
  is_encrypted boolean default true not null,
  metadata jsonb default '{}', -- Additional file metadata
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null,
  
  -- Ensure document belongs to either a quote or request (but not both)
  constraint documents_parent_check check (
    (quote_id is not null and request_id is null) or
    (quote_id is null and request_id is not null)
  )
);

-- Add table comment
comment on table public.documents is 'Document storage references with access control and metadata';

-- Create indexes for better performance
create index documents_quote_id_idx on public.documents (quote_id);
create index documents_request_id_idx on public.documents (request_id);
create index documents_uploaded_by_idx on public.documents (uploaded_by);
create index documents_document_type_idx on public.documents (document_type);
create index documents_access_level_idx on public.documents (access_level);
create index documents_created_at_idx on public.documents (created_at desc);
create index documents_storage_path_idx on public.documents (storage_path);

-- Enable Row Level Security
alter table public.documents enable row level security;

-- RLS Policies for documents table

-- Select policy: Users can view documents they uploaded
create policy "Users can view their uploaded documents" on public.documents
for select
to authenticated
using ( uploaded_by = auth.uid() );

-- Select policy: Clients can view documents in their requests
create policy "Clients can view documents in their requests" on public.documents
for select
to authenticated
using ( 
  request_id is not null and
  exists (
    select 1 from public.requests 
    where id = request_id and client_id = auth.uid()
  )
);

-- Select policy: Attorneys can view documents in accepted quotes
create policy "Attorneys can view documents in their quotes" on public.documents
for select
to authenticated
using ( 
  quote_id is not null and
  exists (
    select 1 from public.quotes 
    where id = quote_id and attorney_id = auth.uid() and status = 'accepted'
  )
);

-- Select policy: Shared documents are viewable by quote participants
create policy "Quote participants can view shared documents" on public.documents
for select
to authenticated
using ( 
  access_level in ('shared', 'public') and
  quote_id is not null and
  exists (
    select 1 from public.quotes q
    join public.requests r on q.request_id = r.id
    where q.id = quote_id and 
    (q.attorney_id = auth.uid() or r.client_id = auth.uid())
  )
);

-- Select policy: Admins can view all documents
create policy "Admins can view all documents" on public.documents
for select
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Insert policy: Users can upload documents to their requests
create policy "Clients can upload documents to their requests" on public.documents
for insert
to authenticated
with check ( 
  uploaded_by = auth.uid() and
  request_id is not null and
  exists (
    select 1 from public.requests 
    where id = request_id and client_id = auth.uid()
  )
);

-- Insert policy: Attorneys can upload documents to their accepted quotes
create policy "Attorneys can upload documents to their quotes" on public.documents
for insert
to authenticated
with check ( 
  uploaded_by = auth.uid() and
  quote_id is not null and
  exists (
    select 1 from public.quotes 
    where id = quote_id and attorney_id = auth.uid() and status = 'accepted'
  )
);

-- Update policy: Users can update their own documents
create policy "Users can update their uploaded documents" on public.documents
for update
to authenticated
using ( uploaded_by = auth.uid() )
with check ( 
  uploaded_by = auth.uid() and
  -- Prevent changing critical fields
  quote_id = old.quote_id and
  request_id = old.request_id and
  storage_path = old.storage_path
);

-- Update policy: Admins can update all documents
create policy "Admins can update all documents" on public.documents
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

-- Delete policy: Users can delete their own documents
create policy "Users can delete their uploaded documents" on public.documents
for delete
to authenticated
using ( uploaded_by = auth.uid() );

-- Delete policy: Admins can delete any document
create policy "Admins can delete documents" on public.documents
for delete
to authenticated
using ( 
  exists (
    select 1 from public.profiles 
    where id = auth.uid() and role = 'admin'
  )
);

-- Trigger to automatically update updated_at
create trigger documents_updated_at
  before update on public.documents
  for each row
  execute function public.handle_updated_at();

-- Function to validate file upload constraints
create or replace function public.validate_document_upload()
returns trigger as $$
begin
  -- Validate file size (max 50MB)
  if new.file_size > 52428800 then
    raise exception 'File size cannot exceed 50MB';
  end if;
  
  -- Validate file type (basic validation)
  if new.file_type not similar to '(application|image|text)/%' then
    raise exception 'Invalid file type: %', new.file_type;
  end if;
  
  -- Set storage path if not provided
  if new.storage_path is null or new.storage_path = '' then
    new.storage_path = concat(
      extract(year from now()), '/',
      extract(month from now()), '/',
      new.uploaded_by, '/',
      new.id, '_', new.file_name
    );
  end if;
  
  return new;
end;
$$ language plpgsql;

-- Trigger to validate document uploads
create trigger documents_upload_validator
  before insert on public.documents
  for each row
  execute function public.validate_document_upload();
