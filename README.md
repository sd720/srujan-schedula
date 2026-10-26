# PearlThoughts Internship – Schedule Project Module: ER Diagram & Loom Submission

This repository contains the complete Entity-Relationship (ER) diagram, database schema design, and presentation kit for the **Schedule Project Module** at PearlThoughts, aligned with the [Weekly Plans Document](https://github.com/PearlThoughtsInternship/Internship-Obsidian-Vault/blob/main/Programme-Structure/Weekly-Plans.md).

---

## 📁 Submission Files Overview

| File | Purpose | Description |
|---|---|---|
| [**`SCHEDULE_MODULE_ER_DIAGRAM.md`**](file:///c:/pearlthought/SCHEDULE_MODULE_ER_DIAGRAM.md) | **Official Specification** | Complete ER diagram (Mermaid syntax), entity attribute dictionary, relationship table, and design rationale. |
| [**`LOOM_VIDEO_RECORDING_SCRIPT.md`**](file:///c:/pearlthought/LOOM_VIDEO_RECORDING_SCRIPT.md) | **Loom Presentation Kit** | Word-for-word presentation script with exact timestamps (0:00–4:00), cues on what to show on screen, and a 2-minute quick version. |
| [**`database_schema.sql`**](file:///c:/pearlthought/database_schema.sql) | **SQL DDL Implementation** | Production-ready PostgreSQL 3NF DDL schema with constraints, unique slot locks, enums, indexes, and sample seed data. |
| [**`index.html`**](file:///c:/pearlthought/index.html) | **Interactive ER Dashboard** | Web visualizer with live ER diagram rendering, zoom/pan controls, module filters, and an in-browser **Loom Teleprompter drawer** for effortless recording. |

---

## 🏛️ Module Architecture (Strict Order)

As requested, the ER diagram strictly models the following five modules in order:

```
┌────────────────────────────────────────────────────────┐
│                   1. USER MODULE                       │
│  - USERS (Central Auth, Google OAuth, Roles, Verified) │
│  - USER_VERIFICATIONS (OTP / Email Verification)       │
└──────────────────────────┬─────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
┌─────────────────────────┐ ┌──────────────────────────────────┐
│    2. PATIENT MODULE    │ │        3. DOCTOR MODULE          │
│ - PATIENTS              │ │ - DOCTORS                        │
│   (1:1 with USERS,      │ │   (1:1 with USERS, Speciality,   │
│   Demographics, Notes)  │ │   Fees, Ratings for Discovery)   │
└────────────┬────────────┘ └─────────────────┬────────────────┘
             │                                │
             │                                ▼
             │              ┌──────────────────────────────────┐
             │              │     4. AVAILABILITY MODULE       │
             │              │ - DOCTOR_AVAILABILITY_SLOTS      │
             │              │   (Doctor ↔ Slot: 1:N)           │
             │              │ - TIME_SLOTS                     │
             │              │   (Slot ↔ Time: 1:N)             │
             │              └─────────────────┬────────────────┘
             │                                │
             ▼                                ▼
┌────────────────────────────────────────────────────────┐
│                 5. APPOINTMENT MODULE                  │
│  - APPOINTMENTS (Patient N:1, Doctor N:1, TimeSlot 1:1)│
│  - RESCHEDULE_HISTORIES (Appointment ↔ History: 1:N)   │
│  - NOTIFICATIONS (Automated Booking Confirmation & OTP)│
└────────────────────────────────────────────────────────┘
```

---

## 🔗 Key Relationships & Weekly Plans Compliance

1. **User ↔ Patient & User ↔ Doctor (`1:1`)**:
   - Implements role-based registration (`PATIENT` vs `DOCTOR`) with Google OAuth and OTP verification (Week 1).
2. **Doctor ↔ Slot (`1:N`)**:
   - `DOCTOR_AVAILABILITY_SLOTS` captures the doctor's scheduled working shift on a specific calendar date (Week 2).
3. **Slot ↔ Time (`1:N`)**:
   - `TIME_SLOTS` generates atomic 30-minute bookable slots with `status` (`AVAILABLE`, `BOOKED`, `RESERVED`, `BLOCKED`).
4. **Appointment ↔ Patient (`N:1`) & Appointment ↔ Doctor (`N:1`)**:
   - Patients can book multiple appointments with doctors (Week 2).
5. **Appointment ↔ Time Slot (`1:1 Unique Constraint`)**:
   - Guarantees zero double booking at the database engine level.
6. **Appointment ↔ RescheduleHistory (`1:N`)**:
   - Captures previous slot, new slot, reason, and initiator for full audit traceability (Week 3).
7. **Appointment ↔ Notification (`1:N`)**:
   - Dispatches: *"Your appointment with Dr. XYZ on DD/MM/YYYY at HH:MM is confirmed."*

---

## 🚀 How to Open the Interactive Dashboard for Your Loom Recording

You can open `index.html` directly in any web browser:
1. Double-click [**`index.html`**](file:///c:/pearlthought/index.html) or open via your browser (`file:///C:/pearlthought/index.html`).
2. Click the purple **"Loom Video Script"** button in the top right corner to open the teleprompter drawer.
3. Start your Loom screen recording, position your camera bubble in the bottom corner, and follow the script!
