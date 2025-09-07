# Product Requirements Document (PRD)

**Project Name:** LinkToLawyers Mobile App  
**Platforms:** Expo React Native (mobile), Supabase (backend)  
**Owner:** James L. Mueller  
**Date:** 2025-09-05  

---

## 1. Overview

LinkToLawyers is a two-sided legal marketplace connecting clients seeking legal services with qualified attorneys. The mobile platform enables clients to submit legal needs, receive competitive attorney quotes, compare proposals, and manage communications securely. Attorneys can efficiently review requests, provide quotes, and schedule consultations. Admins manage the ecosystem and oversee quality.

---

## 2. Goals & Objectives

- Streamline the attorney-client matching process.  
- Provide clients with transparency and choice.  
- Offer attorneys a structured, lead-driven platform.  
- Ensure secure messaging, document handling, and consultation scheduling.  
- Roll out in phases to minimize risk and complexity.  

---

## 3. Target Users

- **Clients:** Individuals or businesses seeking legal representation.  
- **Attorneys:** Licensed legal professionals providing services.  
- **Admins:** Platform operators managing users, requests, and compliance.  

---

## 4. Core Features (MVP Scope)

### Authentication & Onboarding
- Email/password auth (Supabase Auth).  
- Role-based sign-up: Client, Attorney, Admin.  
- Profile setup (basic info, legal specialization for attorneys).  

### Dashboards
- **Client Dashboard:** Track requests, quotes, messages, consultations.  
- **Attorney Dashboard:** Manage invitations, quotes, client comms.  
- **Admin Dashboard:** Manage matching, oversee requests, invite attorneys.  

### Client Workflow
- Multi-step request form (case type, description, documents).  
- Receive multiple attorney quotes (1 per attorney per request).  
- Accept/decline quotes (only 1 acceptance allowed).  
- Messaging with accepted attorney.  
- Consultation scheduling.  

### Attorney Workflow
- Review invitations.  
- Submit 1 quote per request.  
- Messaging + consultation scheduling with clients.  
- Case status (Active/Inactive for records only).  

### Admin Workflow
- Review client submissions.  
- Match & invite attorneys to quote.  
- Monitor activity.  

### Shared Features
- Secure messaging.  
- Document management (upload, view).  
- Scheduling consultations (basic calendar).  

---

## 5. Non-Functional Requirements

- **Responsive:** Mobile-friendly across iOS and Android.  
- **Security:** Encrypted data (Supabase, role-based policies).  
- **Scalability:** Handle growth in users and requests.  
- **Compliance:** Adhere to legal/ethical handling of client data.  

---

## 6. Architecture

- **Frontend:** Expo React Native (managed workflow).  
- **Backend:** Supabase (Postgres DB, Auth, Storage, RLS policies).  
- **Messaging:** Supabase Realtime channels.  
- **Scheduling:** Supabase + third-party calendar integration (Phase 2).  
- **Document Storage:** Supabase Storage with role-based access.  

---

## 7. Database Schema (MVP)

### Profiles
- id (PK)  
- role (client/attorney/admin)  
- email, password (Supabase Auth)  
- profile details (JSONB for flexibility)  

### Requests
- id (PK)  
- client_id (FK Users)  
- description  
- status (open, matched, closed)  

### Quotes
- id (PK)  
- request_id (FK Requests)  
- attorney_id (FK Users)  
- proposal_text  
- fee_amount  
- status (pending, accepted, declined)  

### Messages
- id (PK)  
- quote_id (FK Quotes)  
- sender_id (FK Users)  
- message_text  
- timestamp  

### Documents
- id (PK)  
- quote_id (FK Quotes)  
- storage_url  
- uploaded_by  

### Consultations
- id (PK)  
- quote_id (FK Quotes)  
- date_time  
- status (scheduled, completed, cancelled)  

---

## 8. Phased Rollout Plan

### Phase 1 – Foundations (MVP)
- Authentication (Supabase Auth).  
- Role-based dashboards (basic).  
- Client request submission.  
- Admin invites attorneys.  
- Attorneys submit quotes.  
- Client can accept/decline quotes.  

### Phase 2 – Communication & Docs
- Messaging system (Supabase Realtime).  
- Document upload & sharing (Supabase Storage).  
- Notifications (push/email).  

### Phase 3 – Scheduling
- Consultation scheduling (basic date/time selection).  
- Calendar sync (Google/Outlook API integration optional).  

### Phase 4 – Admin Enhancements
- Admin tools for monitoring usage.  
- Reporting dashboards.  
- Attorney verification process.  

### Phase 5 – Optimization
- UI/UX refinements.  
- Performance improvements.  
- Scaling for larger user base.  

---

## 9. Risks & Mitigation

- **Project creep:** Stick to phased rollouts.  
- **Data sensitivity:** Implement Supabase RLS and encrypted storage.  
- **Attorney adoption:** Ensure simple onboarding.  
- **Legal compliance:** Add disclaimers and strict ToS.  

---

## 10. Success Metrics

- Number of client requests submitted.  
- Number of quotes per request.  
- Quote acceptance rate.  
- Active conversations (messaging engagement).  
- Consultations scheduled.  
