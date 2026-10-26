-- =============================================================================
-- PearlThoughts Internship Programme: Schedule Project Module
-- Database Schema Definition (PostgreSQL 14+)
-- Designed in 3NF conforming to Weekly Plans Specification
-- Modules:
--   1. User Module (Auth, Roles, Verification)
--   2. Patient Module (Patient Profiles)
--   3. Doctor Module (Doctor Profiles, Specialties, Ratings)
--   4. Availability Module (Doctor Availability Slots & Time Slots)
--   5. Appointment Module (Appointments, Reschedule History & Notifications)
-- =============================================================================

-- Enable UUID extension for robust distributed primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. USER MODULE
-- =============================================================================

CREATE TYPE user_role_enum AS ENUM ('PATIENT', 'DOCTOR', 'ADMIN');
CREATE TYPE auth_provider_enum AS ENUM ('LOCAL', 'GOOGLE');
CREATE TYPE user_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE verification_type_enum AS ENUM ('REGISTRATION', 'LOGIN', 'PASSWORD_RESET');

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255), -- Nullable for Google OAuth users
    role user_role_enum NOT NULL DEFAULT 'PATIENT',
    auth_provider auth_provider_enum NOT NULL DEFAULT 'LOCAL',
    google_id VARCHAR(255) UNIQUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    status user_status_enum NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_verifications (
    verification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    otp_code VARCHAR(6) NOT NULL,
    token_type verification_type_enum NOT NULL DEFAULT 'REGISTRATION',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_user_verifications_user_code ON user_verifications(user_id, otp_code);

-- =============================================================================
-- 2. PATIENT MODULE
-- =============================================================================

CREATE TYPE gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER');

CREATE TABLE patients (
    patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender gender_enum,
    blood_group VARCHAR(5),
    emergency_contact VARCHAR(20),
    address TEXT,
    medical_history_summary TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_patients_user_id ON patients(user_id);

-- =============================================================================
-- 3. DOCTOR MODULE
-- =============================================================================

CREATE TABLE doctors (
    doctor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(150) NOT NULL,
    qualification VARCHAR(255) NOT NULL,
    experience_years INTEGER NOT NULL DEFAULT 0,
    consultation_fee NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    rating_avg NUMERIC(3, 2) NOT NULL DEFAULT 5.00,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    bio TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_doctors_specialization ON doctors(specialization);
CREATE INDEX idx_doctors_rating ON doctors(rating_avg DESC);

-- =============================================================================
-- 4. AVAILABILITY MODULE (Doctor ↔ Slot: 1:N | Slot ↔ Time: 1:N)
-- =============================================================================

CREATE TABLE doctor_availability_slots (
    slot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration_minutes INTEGER NOT NULL DEFAULT 30,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_slot_time_range CHECK (end_time > start_time)
);

CREATE TYPE time_slot_status_enum AS ENUM ('AVAILABLE', 'RESERVED', 'BOOKED', 'BLOCKED');

CREATE TABLE time_slots (
    time_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slot_id UUID NOT NULL REFERENCES doctor_availability_slots(slot_id) ON DELETE CASCADE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status time_slot_status_enum NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_time_range CHECK (end_time > start_time)
);

CREATE INDEX idx_avail_doctor_date ON doctor_availability_slots(doctor_id, slot_date);
CREATE INDEX idx_time_slots_slot_status ON time_slots(slot_id, status);

-- =============================================================================
-- 5. APPOINTMENT MODULE (Patient ↔ Appt: N:1 | Doctor ↔ Appt: N:1 | Appt ↔ History: 1:N)
-- =============================================================================

CREATE TYPE appointment_status_enum AS ENUM ('CONFIRMED', 'COMPLETED', 'CANCELLED', 'RESCHEDULED');
CREATE TYPE reschedule_initiator_enum AS ENUM ('PATIENT', 'DOCTOR', 'SYSTEM');
CREATE TYPE notification_type_enum AS ENUM ('BOOKING_CONFIRMATION', 'REMINDER', 'RESCHEDULED', 'CANCELLED');

CREATE TABLE appointments (
    appointment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE RESTRICT,
    doctor_id UUID NOT NULL REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    time_id UUID NOT NULL UNIQUE REFERENCES time_slots(time_id) ON DELETE RESTRICT,
    appointment_date DATE NOT NULL,
    status appointment_status_enum NOT NULL DEFAULT 'CONFIRMED',
    reason_for_visit TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reschedule_histories (
    reschedule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    old_time_id UUID NOT NULL REFERENCES time_slots(time_id),
    new_time_id UUID NOT NULL REFERENCES time_slots(time_id),
    reschedule_reason TEXT,
    rescheduled_by reschedule_initiator_enum NOT NULL DEFAULT 'PATIENT',
    rescheduled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    type notification_type_enum NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appts_patient ON appointments(patient_id);
CREATE INDEX idx_appts_doctor ON appointments(doctor_id);
CREATE INDEX idx_appts_date_status ON appointments(appointment_date, status);
CREATE INDEX idx_reschedule_appt ON reschedule_histories(appointment_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- =============================================================================
-- SAMPLE SEED DATA FOR TESTING / DEMONSTRATION
-- =============================================================================

-- Seed User 1: Patient
INSERT INTO users (user_id, email, phone, role, auth_provider, is_verified)
VALUES ('11111111-1111-1111-1111-111111111111', 'rahul.patient@pearlthoughts.com', '+919876543210', 'PATIENT', 'LOCAL', TRUE);

INSERT INTO patients (patient_id, user_id, first_name, last_name, date_of_birth, gender, blood_group)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Rahul', 'Sharma', '1995-04-15', 'MALE', 'O+');

-- Seed User 2: Doctor
INSERT INTO users (user_id, email, phone, role, auth_provider, is_verified)
VALUES ('22222222-2222-2222-2222-222222222222', 'dr.ananya@pearlthoughts.com', '+919876501234', 'DOCTOR', 'GOOGLE', TRUE);

INSERT INTO doctors (doctor_id, user_id, first_name, last_name, specialization, qualification, experience_years, consultation_fee, rating_avg, total_reviews)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'Dr. Ananya', 'Verma', 'Cardiologist', 'MBBS, MD (Cardiology)', 10, 800.00, 4.95, 128);

-- Seed Availability Slot (Oct 28, 2026: 09:00 - 11:00)
INSERT INTO doctor_availability_slots (slot_id, doctor_id, slot_date, start_time, end_time, slot_duration_minutes)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '2026-10-28', '09:00:00', '11:00:00', 30);

-- Seed Time Slots
INSERT INTO time_slots (time_id, slot_id, start_time, end_time, status) VALUES
('ddddddd1-dddd-dddd-dddd-ddddddddddd1', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '09:00:00', '09:30:00', 'BOOKED'),
('ddddddd2-dddd-dddd-dddd-ddddddddddd2', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '09:30:00', '10:00:00', 'AVAILABLE'),
('ddddddd3-dddd-dddd-dddd-ddddddddddd3', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '10:00:00', '10:30:00', 'AVAILABLE'),
('ddddddd4-dddd-dddd-dddd-ddddddddddd4', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '10:30:00', '11:00:00', 'AVAILABLE');

-- Seed Appointment
INSERT INTO appointments (appointment_id, patient_id, doctor_id, time_id, appointment_date, status, reason_for_visit)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ddddddd1-dddd-dddd-dddd-ddddddddddd1', '2026-10-28', 'CONFIRMED', 'Routine heart wellness checkup');

-- Seed Confirmation Notification
INSERT INTO notifications (notification_id, user_id, appointment_id, type, message)
VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'BOOKING_CONFIRMATION', 'Your appointment with Dr. Ananya Verma on 28/10/2026 at 09:00 AM is confirmed.');
