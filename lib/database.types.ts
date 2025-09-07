// TypeScript types for LinkToLawyers database schema
// Generated from actual database schema

export type Json =
	| string
	| number
	| boolean
	| null
	| { [key: string]: Json | undefined }
	| Json[];

export interface Database {
	public: {
		Tables: {
			profiles: {
				Row: {
					id: string;
					role: Database["public"]["Enums"]["user_role"];
					email: string;
					first_name: string | null;
					last_name: string | null;
					phone: string | null;
					location: string | null;
					jurisdiction: string | null;
					verification_status: string;
					specializations: string[] | null;
					bio: string | null;
					profile_details: Json;
					created_at: string;
					updated_at: string;
				};
				Insert: {
					id: string;
					role?: Database["public"]["Enums"]["user_role"];
					email: string;
					first_name?: string | null;
					last_name?: string | null;
					phone?: string | null;
					location?: string | null;
					jurisdiction?: string | null;
					verification_status?: string;
					specializations?: string[] | null;
					bio?: string | null;
					profile_details?: Json;
					created_at?: string;
					updated_at?: string;
				};
				Update: {
					id?: string;
					role?: Database["public"]["Enums"]["user_role"];
					email?: string;
					first_name?: string | null;
					last_name?: string | null;
					phone?: string | null;
					location?: string | null;
					jurisdiction?: string | null;
					verification_status?: string;
					specializations?: string[] | null;
					bio?: string | null;
					profile_details?: Json;
					created_at?: string;
					updated_at?: string;
				};
			};
			requests: {
				Row: {
					id: number;
					client_id: string;
					title: string;
					description: string;
					case_type: Database["public"]["Enums"]["case_type"];
					urgency_level: Database["public"]["Enums"]["urgency_level"];
					budget_min: number | null;
					budget_max: number | null;
					location: string | null;
					jurisdiction: string | null;
					preferred_language: string;
					status: Database["public"]["Enums"]["request_status"];
					admin_notes: string | null;
					metadata: Json;
					created_at: string;
					updated_at: string;
					submitted_at: string | null;
					closed_at: string | null;
				};
				Insert: {
					client_id: string;
					title: string;
					description: string;
					case_type: Database["public"]["Enums"]["case_type"];
					urgency_level?: Database["public"]["Enums"]["urgency_level"];
					budget_min?: number | null;
					budget_max?: number | null;
					location?: string | null;
					jurisdiction?: string | null;
					preferred_language?: string;
					status?: Database["public"]["Enums"]["request_status"];
					admin_notes?: string | null;
					metadata?: Json;
					created_at?: string;
					updated_at?: string;
					submitted_at?: string | null;
					closed_at?: string | null;
				};
				Update: {
					client_id?: string;
					title?: string;
					description?: string;
					case_type?: Database["public"]["Enums"]["case_type"];
					urgency_level?: Database["public"]["Enums"]["urgency_level"];
					budget_min?: number | null;
					budget_max?: number | null;
					location?: string | null;
					jurisdiction?: string | null;
					preferred_language?: string;
					status?: Database["public"]["Enums"]["request_status"];
					admin_notes?: string | null;
					metadata?: Json;
					created_at?: string;
					updated_at?: string;
					submitted_at?: string | null;
					closed_at?: string | null;
				};
			};
			quotes: {
				Row: {
					id: number;
					request_id: number;
					attorney_id: string;
					proposal_text: string;
					fee_amount: number | null;
					fee_structure: string | null;
					estimated_timeline: string | null;
					terms_and_conditions: string | null;
					status:
						| "draft"
						| "submitted"
						| "under_review"
						| "accepted"
						| "declined"
						| "withdrawn"
						| "expired";
					admin_notes: string | null;
					metadata: Record<string, any>;
					created_at: string;
					updated_at: string;
					submitted_at: string | null;
					accepted_at: string | null;
					declined_at: string | null;
					expires_at: string | null;
				};
				Insert: {
					request_id: number;
					attorney_id: string;
					proposal_text: string;
					fee_amount?: number | null;
					fee_structure?: string | null;
					estimated_timeline?: string | null;
					terms_and_conditions?: string | null;
					status?:
						| "draft"
						| "submitted"
						| "under_review"
						| "accepted"
						| "declined"
						| "withdrawn"
						| "expired";
					admin_notes?: string | null;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
					submitted_at?: string | null;
					accepted_at?: string | null;
					declined_at?: string | null;
					expires_at?: string | null;
				};
				Update: {
					request_id?: number;
					attorney_id?: string;
					proposal_text?: string;
					fee_amount?: number | null;
					fee_structure?: string | null;
					estimated_timeline?: string | null;
					terms_and_conditions?: string | null;
					status?:
						| "draft"
						| "submitted"
						| "under_review"
						| "accepted"
						| "declined"
						| "withdrawn"
						| "expired";
					admin_notes?: string | null;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
					submitted_at?: string | null;
					accepted_at?: string | null;
					declined_at?: string | null;
					expires_at?: string | null;
				};
			};
			messages: {
				Row: {
					id: number;
					quote_id: number;
					sender_id: string;
					recipient_id: string;
					message_type:
						| "text"
						| "system"
						| "document_share"
						| "appointment_request";
					subject: string | null;
					message_text: string;
					is_read: boolean;
					read_at: string | null;
					metadata: Record<string, any>;
					created_at: string;
					updated_at: string;
				};
				Insert: {
					quote_id: number;
					sender_id: string;
					recipient_id: string;
					message_type?:
						| "text"
						| "system"
						| "document_share"
						| "appointment_request";
					subject?: string | null;
					message_text: string;
					is_read?: boolean;
					read_at?: string | null;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
				};
				Update: {
					quote_id?: number;
					sender_id?: string;
					recipient_id?: string;
					message_type?:
						| "text"
						| "system"
						| "document_share"
						| "appointment_request";
					subject?: string | null;
					message_text?: string;
					is_read?: boolean;
					read_at?: string | null;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
				};
			};
			documents: {
				Row: {
					id: number;
					quote_id: number | null;
					request_id: number | null;
					uploaded_by: string;
					file_name: string;
					file_size: number;
					file_type: string;
					document_type:
						| "contract"
						| "evidence"
						| "identification"
						| "financial_statement"
						| "legal_document"
						| "correspondence"
						| "image"
						| "other";
					access_level: "private" | "shared" | "public";
					storage_path: string;
					storage_bucket: string;
					description: string | null;
					is_encrypted: boolean;
					metadata: Record<string, any>;
					created_at: string;
					updated_at: string;
				};
				Insert: {
					quote_id?: number | null;
					request_id?: number | null;
					uploaded_by: string;
					file_name: string;
					file_size: number;
					file_type: string;
					document_type?:
						| "contract"
						| "evidence"
						| "identification"
						| "financial_statement"
						| "legal_document"
						| "correspondence"
						| "image"
						| "other";
					access_level?: "private" | "shared" | "public";
					storage_path: string;
					storage_bucket?: string;
					description?: string | null;
					is_encrypted?: boolean;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
				};
				Update: {
					quote_id?: number | null;
					request_id?: number | null;
					uploaded_by?: string;
					file_name?: string;
					file_size?: number;
					file_type?: string;
					document_type?:
						| "contract"
						| "evidence"
						| "identification"
						| "financial_statement"
						| "legal_document"
						| "correspondence"
						| "image"
						| "other";
					access_level?: "private" | "shared" | "public";
					storage_path?: string;
					storage_bucket?: string;
					description?: string | null;
					is_encrypted?: boolean;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
				};
			};
			consultations: {
				Row: {
					id: number;
					quote_id: number;
					client_id: string;
					attorney_id: string;
					consultation_type:
						| "initial_consultation"
						| "follow_up"
						| "case_review"
						| "document_review"
						| "strategy_session"
						| "other";
					title: string;
					description: string | null;
					scheduled_date: string;
					scheduled_time: string;
					duration_minutes: number;
					timezone: string;
					location: string | null;
					meeting_url: string | null;
					status:
						| "requested"
						| "confirmed"
						| "rescheduled"
						| "completed"
						| "cancelled"
						| "no_show";
					client_notes: string | null;
					attorney_notes: string | null;
					admin_notes: string | null;
					reminder_sent: boolean;
					metadata: Record<string, any>;
					created_at: string;
					updated_at: string;
					confirmed_at: string | null;
					completed_at: string | null;
					cancelled_at: string | null;
				};
				Insert: {
					quote_id: number;
					client_id: string;
					attorney_id: string;
					consultation_type?:
						| "initial_consultation"
						| "follow_up"
						| "case_review"
						| "document_review"
						| "strategy_session"
						| "other";
					title: string;
					description?: string | null;
					scheduled_date: string;
					scheduled_time: string;
					duration_minutes?: number;
					timezone?: string;
					location?: string | null;
					meeting_url?: string | null;
					status?:
						| "requested"
						| "confirmed"
						| "rescheduled"
						| "completed"
						| "cancelled"
						| "no_show";
					client_notes?: string | null;
					attorney_notes?: string | null;
					admin_notes?: string | null;
					reminder_sent?: boolean;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
					confirmed_at?: string | null;
					completed_at?: string | null;
					cancelled_at?: string | null;
				};
				Update: {
					quote_id?: number;
					client_id?: string;
					attorney_id?: string;
					consultation_type?:
						| "initial_consultation"
						| "follow_up"
						| "case_review"
						| "document_review"
						| "strategy_session"
						| "other";
					title?: string;
					description?: string | null;
					scheduled_date?: string;
					scheduled_time?: string;
					duration_minutes?: number;
					timezone?: string;
					location?: string | null;
					meeting_url?: string | null;
					status?:
						| "requested"
						| "confirmed"
						| "rescheduled"
						| "completed"
						| "cancelled"
						| "no_show";
					client_notes?: string | null;
					attorney_notes?: string | null;
					admin_notes?: string | null;
					reminder_sent?: boolean;
					metadata?: Record<string, any>;
					created_at?: string;
					updated_at?: string;
					confirmed_at?: string | null;
					completed_at?: string | null;
					cancelled_at?: string | null;
				};
			};
		};
		Views: {
			[_ in never]: never;
		};
		Functions: {
			[_ in never]: never;
		};
		Enums: {
			user_role: "client" | "attorney" | "admin";
			request_status:
				| "draft"
				| "submitted"
				| "under_review"
				| "open_for_quotes"
				| "matched"
				| "closed"
				| "cancelled";
			case_type:
				| "personal_injury"
				| "family_law"
				| "criminal_defense"
				| "business_law"
				| "real_estate"
				| "immigration"
				| "employment_law"
				| "estate_planning"
				| "bankruptcy"
				| "intellectual_property"
				| "tax_law"
				| "other";
			urgency_level: "low" | "medium" | "high" | "urgent";
			quote_status:
				| "draft"
				| "submitted"
				| "under_review"
				| "accepted"
				| "declined"
				| "withdrawn"
				| "expired";
			message_type:
				| "text"
				| "system"
				| "document_share"
				| "appointment_request";
			document_type:
				| "contract"
				| "evidence"
				| "identification"
				| "financial_statement"
				| "legal_document"
				| "correspondence"
				| "image"
				| "other";
			document_access_level: "private" | "shared" | "public";
			consultation_status:
				| "requested"
				| "confirmed"
				| "rescheduled"
				| "completed"
				| "cancelled"
				| "no_show";
			consultation_type:
				| "initial_consultation"
				| "follow_up"
				| "case_review"
				| "document_review"
				| "strategy_session"
				| "other";
		};
		CompositeTypes: {
			[_ in never]: never;
		};
	};
}
