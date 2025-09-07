import { supabase } from '@/config/supabase';
import { Database } from './database.types';

// Type aliases for easier usage
export type Profile = Database['public']['Tables']['profiles']['Row'];
export type ProfileInsert = Database['public']['Tables']['profiles']['Insert'];
export type ProfileUpdate = Database['public']['Tables']['profiles']['Update'];

export type Request = Database['public']['Tables']['requests']['Row'];
export type RequestInsert = Database['public']['Tables']['requests']['Insert'];
export type RequestUpdate = Database['public']['Tables']['requests']['Update'];

export type Quote = Database['public']['Tables']['quotes']['Row'];
export type QuoteInsert = Database['public']['Tables']['quotes']['Insert'];
export type QuoteUpdate = Database['public']['Tables']['quotes']['Update'];

export type Message = Database['public']['Tables']['messages']['Row'];
export type MessageInsert = Database['public']['Tables']['messages']['Insert'];
export type MessageUpdate = Database['public']['Tables']['messages']['Update'];

export type Document = Database['public']['Tables']['documents']['Row'];
export type DocumentInsert = Database['public']['Tables']['documents']['Insert'];
export type DocumentUpdate = Database['public']['Tables']['documents']['Update'];

export type Consultation = Database['public']['Tables']['consultations']['Row'];
export type ConsultationInsert = Database['public']['Tables']['consultations']['Insert'];
export type ConsultationUpdate = Database['public']['Tables']['consultations']['Update'];

// Enum types
export type UserRole = Database['public']['Enums']['user_role'];
export type RequestStatus = Database['public']['Enums']['request_status'];
export type CaseType = Database['public']['Enums']['case_type'];
export type UrgencyLevel = Database['public']['Enums']['urgency_level'];
export type QuoteStatus = Database['public']['Enums']['quote_status'];
export type MessageType = Database['public']['Enums']['message_type'];
export type DocumentType = Database['public']['Enums']['document_type'];
export type DocumentAccessLevel = Database['public']['Enums']['document_access_level'];
export type ConsultationStatus = Database['public']['Enums']['consultation_status'];
export type ConsultationType = Database['public']['Enums']['consultation_type'];

// Database utility functions
export const db = {
  // Profile operations
  profiles: {
    async getById(id: string) {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', id)
        .single();
      
      if (error) throw error;
      return data;
    },

    async getByRole(role: UserRole) {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('role', role);
      
      if (error) throw error;
      return data;
    },

    async getVerifiedAttorneys() {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('role', 'attorney')
        .eq('verification_status', 'verified');
      
      if (error) throw error;
      return data;
    },

    async update(id: string, updates: ProfileUpdate) {
      const { data, error } = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  },

  // Request operations
  requests: {
    async getByClient(clientId: string) {
      const { data, error } = await supabase
        .from('requests')
        .select('*')
        .eq('client_id', clientId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async getOpen() {
      const { data, error } = await supabase
        .from('requests')
        .select('*')
        .eq('status', 'open_for_quotes')
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async create(request: RequestInsert) {
      const { data, error } = await supabase
        .from('requests')
        .insert(request)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },

    async update(id: number, updates: RequestUpdate) {
      const { data, error } = await supabase
        .from('requests')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  },

  // Quote operations
  quotes: {
    async getByRequest(requestId: number) {
      const { data, error } = await supabase
        .from('quotes')
        .select(`
          *,
          attorney:profiles!quotes_attorney_id_fkey(*)
        `)
        .eq('request_id', requestId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async getByAttorney(attorneyId: string) {
      const { data, error } = await supabase
        .from('quotes')
        .select(`
          *,
          request:requests(*)
        `)
        .eq('attorney_id', attorneyId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async create(quote: QuoteInsert) {
      const { data, error } = await supabase
        .from('quotes')
        .insert(quote)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },

    async accept(id: number) {
      const { data, error } = await supabase
        .from('quotes')
        .update({ status: 'accepted' })
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },

    async decline(id: number) {
      const { data, error } = await supabase
        .from('quotes')
        .update({ status: 'declined' })
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  },

  // Message operations
  messages: {
    async getByQuote(quoteId: number) {
      const { data, error } = await supabase
        .from('messages')
        .select(`
          *,
          sender:profiles!messages_sender_id_fkey(first_name, last_name, role)
        `)
        .eq('quote_id', quoteId)
        .order('created_at', { ascending: true });
      
      if (error) throw error;
      return data;
    },

    async send(message: MessageInsert) {
      const { data, error } = await supabase
        .from('messages')
        .insert(message)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },

    async markAsRead(id: number) {
      const { data, error } = await supabase
        .from('messages')
        .update({ is_read: true })
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  },

  // Document operations
  documents: {
    async getByRequest(requestId: number) {
      const { data, error } = await supabase
        .from('documents')
        .select('*')
        .eq('request_id', requestId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async getByQuote(quoteId: number) {
      const { data, error } = await supabase
        .from('documents')
        .select('*')
        .eq('quote_id', quoteId)
        .order('created_at', { ascending: false });
      
      if (error) throw error;
      return data;
    },

    async create(document: DocumentInsert) {
      const { data, error } = await supabase
        .from('documents')
        .insert(document)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  },

  // Consultation operations
  consultations: {
    async getByQuote(quoteId: number) {
      const { data, error } = await supabase
        .from('consultations')
        .select('*')
        .eq('quote_id', quoteId)
        .order('scheduled_date', { ascending: true });
      
      if (error) throw error;
      return data;
    },

    async getByClient(clientId: string) {
      const { data, error } = await supabase
        .from('consultations')
        .select(`
          *,
          attorney:profiles!consultations_attorney_id_fkey(first_name, last_name)
        `)
        .eq('client_id', clientId)
        .order('scheduled_date', { ascending: true });
      
      if (error) throw error;
      return data;
    },

    async getByAttorney(attorneyId: string) {
      const { data, error } = await supabase
        .from('consultations')
        .select(`
          *,
          client:profiles!consultations_client_id_fkey(first_name, last_name)
        `)
        .eq('attorney_id', attorneyId)
        .order('scheduled_date', { ascending: true });
      
      if (error) throw error;
      return data;
    },

    async create(consultation: ConsultationInsert) {
      const { data, error } = await supabase
        .from('consultations')
        .insert(consultation)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },

    async updateStatus(id: number, status: ConsultationStatus) {
      const { data, error } = await supabase
        .from('consultations')
        .update({ status })
        .eq('id', id)
        .select()
        .single();
      
      if (error) throw error;
      return data;
    }
  }
};

// Constants for enum values
export const CASE_TYPES: Record<CaseType, string> = {
  personal_injury: 'Personal Injury',
  family_law: 'Family Law',
  criminal_defense: 'Criminal Defense',
  business_law: 'Business Law',
  real_estate: 'Real Estate',
  immigration: 'Immigration',
  employment_law: 'Employment Law',
  estate_planning: 'Estate Planning',
  bankruptcy: 'Bankruptcy',
  intellectual_property: 'Intellectual Property',
  tax_law: 'Tax Law',
  other: 'Other'
};

export const URGENCY_LEVELS: Record<UrgencyLevel, string> = {
  low: 'Low',
  medium: 'Medium',
  high: 'High',
  urgent: 'Urgent'
};

export const REQUEST_STATUSES: Record<RequestStatus, string> = {
  draft: 'Draft',
  submitted: 'Submitted',
  under_review: 'Under Review',
  open_for_quotes: 'Open for Quotes',
  matched: 'Matched',
  closed: 'Closed',
  cancelled: 'Cancelled'
};

export const QUOTE_STATUSES: Record<QuoteStatus, string> = {
  draft: 'Draft',
  submitted: 'Submitted',
  under_review: 'Under Review',
  accepted: 'Accepted',
  declined: 'Declined',
  withdrawn: 'Withdrawn',
  expired: 'Expired'
};
