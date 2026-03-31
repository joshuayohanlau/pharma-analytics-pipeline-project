-- Run this against your PostgreSQL server to set up the pharma_analytics database
-- Usage: psql -U postgres -f setup/create_raw_schema.sql

CREATE SCHEMA IF NOT EXISTS raw;

-- Drug master data
CREATE TABLE raw.drugs (
    drug_id SERIAL PRIMARY KEY,
    ndc_code VARCHAR(20) NOT NULL,
    brand_name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200) NOT NULL,
    manufacturer VARCHAR(200) NOT NULL,
    therapeutic_class_code VARCHAR(10),
    dosage_form VARCHAR(100),
    strength VARCHAR(100),
    route_of_administration VARCHAR(100),
    approval_date DATE,
    approval_status VARCHAR(50) DEFAULT 'approved',
    unit_price_cents INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Prescribers (doctors, NPs, etc.)
CREATE TABLE raw.prescribers (
    prescriber_id SERIAL PRIMARY KEY,
    npi_number VARCHAR(10) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(200),
    practice_name VARCHAR(300),
    practice_address VARCHAR(500),
    city VARCHAR(100),
    state_code VARCHAR(2),
    zip_code VARCHAR(10),
    territory_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Patients
CREATE TABLE raw.patients (
    patient_id SERIAL PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    state_code VARCHAR(2),
    zip_code VARCHAR(10),
    insurance_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Pharmacies
CREATE TABLE raw.pharmacies (
    pharmacy_id SERIAL PRIMARY KEY,
    ncpdp_id VARCHAR(10) NOT NULL,
    pharmacy_name VARCHAR(300) NOT NULL,
    pharmacy_type VARCHAR(50),
    chain_name VARCHAR(200),
    city VARCHAR(100),
    state_code VARCHAR(2),
    zip_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Prescriptions (transactional - main fact table)
CREATE TABLE raw.prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    rx_number VARCHAR(20) NOT NULL,
    patient_id INTEGER REFERENCES raw.patients(patient_id),
    prescriber_id INTEGER REFERENCES raw.prescribers(prescriber_id),
    drug_id INTEGER REFERENCES raw.drugs(drug_id),
    pharmacy_id INTEGER REFERENCES raw.pharmacies(pharmacy_id),
    fill_date DATE NOT NULL,
    days_supply INTEGER,
    quantity NUMERIC(10,2),
    total_cost_cents INTEGER,
    copay_cents INTEGER,
    refill_number INTEGER DEFAULT 0,
    is_new_prescription BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    loaded_at TIMESTAMP DEFAULT NOW()
);

-- Adverse events (FDA FAERS style)
CREATE TABLE raw.adverse_events (
    event_id SERIAL PRIMARY KEY,
    case_number VARCHAR(20) NOT NULL,
    patient_id INTEGER REFERENCES raw.patients(patient_id),
    drug_id INTEGER REFERENCES raw.drugs(drug_id),
    event_date DATE,
    reported_date DATE,
    event_type VARCHAR(100),
    severity VARCHAR(20),
    outcome VARCHAR(100),
    description TEXT,
    reporter_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    loaded_at TIMESTAMP DEFAULT NOW()
);

-- Clinical trials
CREATE TABLE raw.clinical_trials (
    trial_id SERIAL PRIMARY KEY,
    nct_number VARCHAR(15) NOT NULL,
    trial_title VARCHAR(500) NOT NULL,
    drug_id INTEGER REFERENCES raw.drugs(drug_id),
    phase VARCHAR(10),
    status VARCHAR(50),
    start_date DATE,
    estimated_end_date DATE,
    actual_end_date DATE,
    target_enrollment INTEGER,
    actual_enrollment INTEGER,
    principal_investigator VARCHAR(200),
    site_count INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Inventory
CREATE TABLE raw.inventory (
    inventory_id SERIAL PRIMARY KEY,
    warehouse_code VARCHAR(10) NOT NULL,
    drug_id INTEGER REFERENCES raw.drugs(drug_id),
    quantity_on_hand INTEGER,
    quantity_reserved INTEGER,
    reorder_point INTEGER,
    last_restock_date DATE,
    expiration_date DATE,
    lot_number VARCHAR(50),
    snapshot_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Sales representatives
CREATE TABLE raw.sales_reps (
    rep_id SERIAL PRIMARY KEY,
    employee_id VARCHAR(10) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    territory_id INTEGER,
    region VARCHAR(50),
    hire_date DATE,
    manager_id INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
