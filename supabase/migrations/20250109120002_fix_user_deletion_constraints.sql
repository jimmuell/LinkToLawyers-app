/*
  Migration: Fix user deletion constraints
  Purpose: Ensure all foreign key constraints allow proper user deletion
  Updates: Update foreign key constraints to handle user deletion gracefully
*/

-- Fix consultations.rescheduled_by to SET NULL on user deletion
ALTER TABLE public.consultations 
DROP CONSTRAINT IF EXISTS consultations_rescheduled_by_fkey;

ALTER TABLE public.consultations 
ADD CONSTRAINT consultations_rescheduled_by_fkey 
FOREIGN KEY (rescheduled_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Fix requests.reviewed_by to SET NULL on user deletion  
ALTER TABLE public.requests 
DROP CONSTRAINT IF EXISTS requests_reviewed_by_fkey;

ALTER TABLE public.requests 
ADD CONSTRAINT requests_reviewed_by_fkey 
FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
