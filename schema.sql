-- =========================================================
-- HOSPITAL APPOINTMENT BOOKING DEMO — FINAL SCHEMA
-- PostgreSQL | Timezone-safe | n8n-friendly | Student portfolio
-- Exactly 4 tables. No triggers. No stored procedures.
-- =========================================================

-- ---------------------------------------------------------
-- 1. DOCTORS
-- ---------------------------------------------------------
CREATE TABLE doctors (
    doctor_id            SERIAL PRIMARY KEY,
    doctor_name          VARCHAR(150) NOT NULL,
    specialization       VARCHAR(150) NOT NULL,
    google_calendar_id   VARCHAR(255) NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_doctors_calendar_id UNIQUE (google_calendar_id)
);

-- ---------------------------------------------------------
-- 2. PATIENTS
-- ---------------------------------------------------------
CREATE TABLE patients (
    patient_id       SERIAL PRIMARY KEY,
    patient_name     VARCHAR(150),
    whatsapp_number  VARCHAR(20) NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_patients_whatsapp_number UNIQUE (whatsapp_number)
);

-- ---------------------------------------------------------
-- 3. APPOINTMENTS
-- ---------------------------------------------------------
CREATE TABLE appointments (
    appointment_id            SERIAL PRIMARY KEY,
    patient_id                INTEGER NOT NULL REFERENCES patients(patient_id) ON DELETE RESTRICT,
    doctor_id                 INTEGER NOT NULL REFERENCES doctors(doctor_id) ON DELETE RESTRICT,

    start_time                TIMESTAMPTZ NOT NULL,
    end_time                  TIMESTAMPTZ NOT NULL,
    appointment_date          DATE GENERATED ALWAYS AS ((start_time AT TIME ZONE 'Asia/Kolkata')::DATE) STORED,

    status                    VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',

    google_calendar_event_id  VARCHAR(255),

    reminder_6h_sent          BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_3h_sent          BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_1h_sent          BOOLEAN NOT NULL DEFAULT FALSE,

    created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_appointments_status
        CHECK (status IN ('SCHEDULED', 'COMPLETED', 'CANCELLED')),

    CONSTRAINT chk_appointments_time_order
        CHECK (end_time > start_time),

    CONSTRAINT uq_appointments_doctor_slot UNIQUE (doctor_id, start_time)
);

-- ---------------------------------------------------------
-- 4. MESSAGES
-- ---------------------------------------------------------
CREATE TABLE messages (
    message_id            SERIAL PRIMARY KEY,
    whatsapp_message_id   VARCHAR(255) NOT NULL,
    patient_id            INTEGER REFERENCES patients(patient_id) ON DELETE SET NULL,
    phone_number          VARCHAR(20) NOT NULL,
    message_text          TEXT NOT NULL,

    is_processed          BOOLEAN NOT NULL DEFAULT FALSE,
    processed_at          TIMESTAMPTZ,

    received_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_messages_whatsapp_message_id UNIQUE (whatsapp_message_id)
);