# Database Setup Guide

This guide will help you set up the LinkToLawyers database schema with all necessary tables, RLS policies, and TypeScript types.

## Prerequisites

- Supabase project configured and connected
- Supabase CLI installed (`npm install -g supabase`)
- Environment variables set up in `.env.local`

## Database Schema Overview

The LinkToLawyers database consists of 6 main tables:

1. **profiles** - User profiles for clients, attorneys, and admins
2. **requests** - Client legal service requests  
3. **quotes** - Attorney proposals for requests
4. **messages** - Secure communications between parties
5. **documents** - File storage references with access control
6. **consultations** - Scheduled meetings between clients and attorneys

## Migration Files Created

The following migration files have been created in `supabase/migrations/`:

- `20250109120000_create_profiles_table.sql`
- `20250109120100_create_requests_table.sql` 
- `20250109120200_create_quotes_table.sql`
- `20250109120300_create_messages_table.sql`
- `20250109120400_create_documents_table.sql`
- `20250109120500_create_consultations_table.sql`

## Applying Migrations

### Default Migration Workflow: `supabase db push`

**IMPORTANT**: Always use `supabase db push` for applying migrations unless explicitly instructed otherwise. This is the preferred and default method for this project.

1. **Initialize Supabase locally** (if not already done):
   ```bash
   npx supabase init
   ```

2. **Link to your remote project**:
   ```bash
   npx supabase link --project-ref YOUR_PROJECT_REF
   ```

3. **Apply all migrations**:
   ```bash
   npx supabase db push
   ```

### Migration History Management

If you encounter migration history conflicts, use the repair commands as suggested by the CLI:

```bash
# Example repair commands (use exact commands provided by CLI)
npx supabase migration repair --status reverted MIGRATION_VERSION
npx supabase migration repair --status applied MIGRATION_VERSION
```

### Alternative: Manual Application (Only when explicitly requested)

Manual migration through the Supabase Dashboard should only be used when specifically requested:

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and paste each migration file content in order
4. Execute each migration one by one

## Post-Migration Steps

### 1. Generate TypeScript Types

After applying migrations, regenerate TypeScript types:

```bash
npx supabase gen types typescript --local > lib/database.types.ts
```

### 2. Verify RLS Policies

All tables have Row Level Security (RLS) enabled with comprehensive policies:

- **Users can access their own data**
- **Role-based access controls** (client/attorney/admin)
- **Secure document sharing** between quote participants
- **Admin oversight** capabilities

### 3. Test Database Functions

Key database functions created:

- `handle_updated_at()` - Auto-updates timestamps
- `handle_new_user()` - Creates profile on user signup
- `handle_request_submission()` - Manages request status changes
- `handle_quote_status_change()` - Ensures quote acceptance logic
- `validate_message_participants()` - Validates secure messaging

## Database Utilities

A comprehensive database utilities file has been created at `lib/database.utils.ts` with:

- **Type aliases** for easier TypeScript usage
- **Database helper functions** for common operations
- **Constants** for enum values and display names

### Usage Example

```typescript
import { db, CASE_TYPES } from '@/lib/database.utils';

// Get client's requests
const requests = await db.requests.getByClient(clientId);

// Create a new quote
const quote = await db.quotes.create({
  request_id: requestId,
  attorney_id: attorneyId,
  proposal_text: "I can help with your case...",
  fee_amount: 5000
});

// Send a message
const message = await db.messages.send({
  quote_id: quoteId,
  sender_id: senderId,
  recipient_id: recipientId,
  message_text: "Hello, I have a question..."
});
```

## Security Features

### Row Level Security (RLS)

Every table has RLS enabled with granular policies:

- **Profile access**: Users see their own + public attorney profiles
- **Request visibility**: Clients see theirs, attorneys see open requests
- **Quote access**: Participants can view/manage their quotes
- **Secure messaging**: Only quote participants can communicate
- **Document sharing**: Role-based access with sharing levels
- **Consultation management**: Participants can schedule/manage meetings

### Data Validation

- **File upload constraints** (50MB max, type validation)
- **Participant validation** for messages and consultations
- **Quote uniqueness** (one per attorney per request)
- **Timeline validation** (no past scheduling)

## Troubleshooting

### Common Issues

1. **Migration fails**: Check table dependencies and foreign key constraints
2. **RLS policy errors**: Ensure user authentication and role setup
3. **Type errors**: Regenerate types after schema changes

### Verification Queries

Test your setup with these queries:

```sql
-- Check if all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verify RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public';

-- Check enum types
SELECT typname FROM pg_type 
WHERE typtype = 'e' 
ORDER BY typname;
```

## Next Steps

After database setup:

1. **Test authentication flow** with profile creation
2. **Implement request submission** workflow  
3. **Build quote management** features
4. **Add messaging capabilities**
5. **Integrate document upload**
6. **Create scheduling system**

## Support

If you encounter issues:

1. Check Supabase logs in the dashboard
2. Verify environment variables are set correctly
3. Ensure your Supabase project has sufficient permissions
4. Review RLS policies for access issues
