# Loom Video Presentation Script: Schedule Project Module ER Diagram
**PearlThoughts Internship Programme – Daily / Weekly Submission**  
**Presenter:** Engineering Intern  
**Target Video Duration:** 3 to 4 minutes (Quick 2-minute elevator pitch also included below)  
**Deliverable:** ER Diagram Walkthrough for Schedule Project Module

---

## 📹 Pre-Recording Setup & Checklist
1. **Loom Settings:**
   - Screen: Full Desktop or Browser Window with the interactive HTML diagram (`index.html`) open.
   - Camera: Enabled (Bottom-left corner circular bubble).
   - Microphone: Checked and clear.
2. **Tabs Ready to Show:**
   - **Tab 1:** `index.html` (The Interactive ER Diagram Dashboard we created).
   - **Tab 2:** `SCHEDULE_MODULE_ER_DIAGRAM.md` or GitHub preview.
   - **Tab 3:** PearlThoughts Weekly Plans document (for reference).
3. **Delivery Style:** Confident, structured, enthusiastic, and strictly adhering to the module order requested.

---

## 🎙️ Complete Word-for-Word Video Script (3 – 4 Minutes)

### [0:00 – 0:30] Introduction & Objective
**[Screen Action]:** *Show your face + Title card on `index.html` displaying "PearlThoughts: Schedule Project Module ER Diagram".*

> "Hello everyone, my name is [Your Name], and I am a software engineering intern at PearlThoughts.
> 
> Today, I am excited to present the Entity-Relationship (ER) diagram for our **Schedule Project Module**, designed strictly according to the PearlThoughts Weekly Plans requirements.
> 
> As outlined in our product roadmap, this architecture powers the end-to-end journey from user registration and Google OAuth onboarding, to doctor discovery, granular slot generation, appointment booking, rescheduling history, and automated notification triggers.
> 
> To ensure clarity, simplicity, and high maintainability, our ER diagram is structured into five sequential modules:
> 1. User Module
> 2. Patient Module
> 3. Doctor Module
> 4. Availability Module
> 5. Appointment Module
> 
> Let’s dive right into each module."

---

### [0:30 – 1:15] Module 1 & Module 2: User Module & Patient Module
**[Screen Action]:** *Zoom in / highlight the **USERS**, **USER_VERIFICATIONS**, and **PATIENTS** tables.*

> "Starting with **Module 1: The User Module**.
> 
> The `USERS` table serves as our central authentication and identity hub. It captures the user's `email`, `phone`, and `password_hash`. As required by Week 1's onboarding spec, we support both standard local authentication and **Google OAuth** social login using the `auth_provider` enum and `google_id`. 
> 
> Role-based access control is enforced right here via the `role` enum, supporting `PATIENT`, `DOCTOR`, and `ADMIN`.
> 
> Attached to `USERS` is `USER_VERIFICATIONS` in a **1-to-Many** relationship, managing short-lived OTP tokens and verification timestamps to ensure every account is verified before accessing clinical features.
> 
> Moving to **Module 2: The Patient Module**.
> 
> Instead of cluttering the authentication table with health data, we decoupled user profiles into the `PATIENTS` entity via a strict **1-to-1 relationship** on `user_id`. This entity stores essential patient demographics—such as date of birth, gender, blood group, emergency contact, and baseline medical notes. This separation of concerns ensures security and compliance with healthcare data privacy."

---

### [1:15 – 1:55] Module 3: Doctor Module
**[Screen Action]:** *Highlight the **DOCTORS** entity and its relationship to `USERS`.*

> "Next is **Module 3: The Doctor Module**.
> 
> Just like patients, doctors extend the `USERS` entity in a **1-to-1 relationship** through the `DOCTORS` table.
> 
> Here, we store professional credentials that directly power the Week 2 requirement: *'Locate doctor by specialty, ratings, and availability'*. 
> 
> We have fields for `specialization`, `qualification`, `experience_years`, and `consultation_fee`. We also track `rating_avg` and `total_reviews` with database indexing, allowing patients to instantly filter and sort doctors by ratings and fees with sub-millisecond query performance."

---

### [1:55 – 2:45] Module 4: Availability Module
**[Screen Action]:** *Point your cursor at the link between `DOCTORS` ➔ `DOCTOR_AVAILABILITY_SLOTS` ➔ `TIME_SLOTS`.*

> "Now let's examine **Module 4: The Availability Module**, which is the core scheduling engine.
> 
> The PearlThoughts specification clearly mandates two key relationships:
> - `Doctor ↔ Slot (1:N)`
> - `Slot ↔ Time (1:N)`
> 
> We modeled this with mathematical precision using two tables:
> 
> First, `DOCTOR_AVAILABILITY_SLOTS` represents the parent availability shift for a doctor on a specific calendar date—for instance, Dr. Ananya is available on October 28th between 9:00 AM and 5:00 PM with 30-minute intervals. One doctor has multiple slots (`1:N`).
> 
> Second, our system automatically segments this shift into granular, individual bookable units in the `TIME_SLOTS` table. Each parent slot produces multiple time slots (`1:N`). 
> 
> Each `TIME_SLOTS` record stores the exact start time, end time, and an atomic `status` enum: `AVAILABLE`, `RESERVED`, `BOOKED`, or `BLOCKED`. This modular 2-tier design prevents scheduling conflicts and allows easy customization of slot intervals."

---

### [2:45 – 3:35] Module 5: Appointment Module (Booking, Rescheduling & Notifications)
**[Screen Action]:** *Highlight **APPOINTMENTS**, **RESCHEDULE_HISTORIES**, and **NOTIFICATIONS**.*

> "Finally, we arrive at **Module 5: The Appointment Module**, which orchestrates booking, cancellations, rescheduling, and notifications.
> 
> In the `APPOINTMENTS` table:
> - It links to `PATIENTS` in an **N-to-1** relationship—one patient can book many appointments.
> - It links to `DOCTORS` in an **N-to-1** relationship—one doctor treats many appointments.
> - Crucially, it has a **1-to-1 unique relationship** with `TIME_SLOTS` via `time_id`. This unique constraint guarantees at the database engine level that no two patients can ever book the exact same time slot—completely eliminating race conditions and double-booking bugs!
> 
> To fulfill the Week 3 **Reschedule Experience**, we implemented the `RESCHEDULE_HISTORIES` entity in a **1-to-Many** relationship with `APPOINTMENTS`. When a patient or doctor reschedules, we log the previous time slot, new time slot, reason, and initiator, maintaining a clean audit trail.
> 
> Lastly, we have the `NOTIFICATIONS` table. When an appointment is confirmed, the backend automatically triggers the exact message specified in our roadmap:
> *'Your appointment with Dr. XYZ on DD/MM/YYYY at HH:MM is confirmed.'*
> It also handles 24-hour reminders and cancellation alerts."

---

### [3:35 – 4:00] Conclusion & Wrap-Up
**[Screen Action]:** *Show the complete zoomed-out ER diagram overview on the screen and smile at the camera.*

> "In summary:
> - Our schema is normalized to **3rd Normal Form (3NF)** with zero redundant data.
> - We strictly satisfy all technical relationships specified in PearlThoughts Week 1, Week 2, and Week 3.
> - Foreign key constraints, cascading deletes where appropriate, and unique slot indexes ensure high data integrity and enterprise scalability.
> 
> Thank you so much for watching my presentation. The complete ER diagram, interactive visualizer, and SQL schema are submitted in the repository. I look forward to your feedback!"

---

## ⚡ Fast 2-Minute Elevator Pitch Version (If Time-Capped)

If your mentor or submission guideline asks for a video strictly under 2 or 2.5 minutes, use this concise script:

> "Hi everyone, I’m [Your Name], engineering intern at PearlThoughts. Here is my ER Diagram walkthrough for the Schedule Project Module covering our five core modules:
> 
> 1. **User Module:** Central `USERS` table handling email/password and Google OAuth, with role-based segregation for Patients and Doctors, backed by `USER_VERIFICATIONS` for OTP authentication.
> 2. **Patient Module:** The `PATIENTS` entity links 1-to-1 with `USERS`, storing demographic and emergency contact details separately for data privacy.
> 3. **Doctor Module:** The `DOCTORS` entity also links 1-to-1 with `USERS`, storing qualifications, specialties, and ratings to power patient doctor discovery.
> 4. **Availability Module:** Directly implements the specified `Doctor ↔ Slot (1:N)` and `Slot ↔ Time (1:N)` architecture. Doctors define date shifts in `DOCTOR_AVAILABILITY_SLOTS`, which dynamically generate granular 30-minute bookable rows in `TIME_SLOTS`.
> 5. **Appointment Module:** The `APPOINTMENTS` entity connects Patients (N:1) and Doctors (N:1) with a strict unique 1:1 lock on `TIME_SLOTS` to eliminate double booking. It includes `RESCHEDULE_HISTORIES` (1:N) for full Week 3 reschedule audit tracking, and automated `NOTIFICATIONS` for booking confirmations and reminders.
> 
> The schema is in 3NF, indexed for search, and ready for our NestJS backend implementation. Thank you!"
