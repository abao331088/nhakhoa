-- Dental Management System Schema (MySQL)
-- Safe to import via phpMyAdmin or mysql CLI

CREATE DATABASE IF NOT EXISTS dental_management_system
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE dental_management_system;

-- Core reference tables first
CREATE TABLE IF NOT EXISTS patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  gender ENUM('Male','Female') NOT NULL,
  birth_date DATE,
  phone VARCHAR(15),
  email VARCHAR(100),
  address VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dentists (
  dentist_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  specialization VARCHAR(100),
  phone VARCHAR(15),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Users (registration/login)
CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  sex ENUM('Male','Female') NOT NULL,
  user_type ENUM('Admin','Doctor','Receptionist','Nurse') NOT NULL,
  dentist_id INT NULL,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  profile_picture VARCHAR(255),
  remember_token VARCHAR(255),
  remember_expires_at DATETIME,
  status ENUM('Active','Inactive') DEFAULT 'Active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email),
  INDEX idx_users_status (status),
  CONSTRAINT fk_users_dentist FOREIGN KEY (dentist_id) REFERENCES dentists(dentist_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ensure remember-me columns exist (for upgrades)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS dentist_id INT NULL AFTER user_type,
  ADD COLUMN IF NOT EXISTS remember_token VARCHAR(255),
  ADD COLUMN IF NOT EXISTS remember_expires_at DATETIME;

-- Add FK separately so repeated imports only need to ignore duplicate-key errors
ALTER TABLE users
  ADD CONSTRAINT fk_users_dentist FOREIGN KEY (dentist_id) REFERENCES dentists(dentist_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Password reset tokens (user-provided schema)
CREATE TABLE IF NOT EXISTS password_resets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  token VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -- Users (for future login)
-- CREATE TABLE IF NOT EXISTS users (
--   user_id INT AUTO_INCREMENT PRIMARY KEY,
--   first_name VARCHAR(50) NOT NULL,
--   last_name VARCHAR(50) NOT NULL,
--   gender ENUM('Male','Female') NOT NULL DEFAULT 'Male',
--   phone VARCHAR(20),
--   email VARCHAR(100) NOT NULL UNIQUE,
--   username VARCHAR(50) NOT NULL UNIQUE,
--   password VARCHAR(255) NOT NULL,
--   role ENUM('Admin','Receptionist','Dentist') DEFAULT 'Receptionist',
--   status ENUM('active','inactive') DEFAULT 'active',
--   profile_picture VARCHAR(255),
--   remember_token VARCHAR(255),
--   remember_expires_at DATETIME,
--   last_login DATETIME,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- ) ENGINE=InnoDB;

-- Appointments
CREATE TABLE IF NOT EXISTS appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  dentist_id INT NOT NULL,
  appointment_date DATETIME NOT NULL,
  reason VARCHAR(255),
  status ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_appointments_dentist FOREIGN KEY (dentist_id) REFERENCES dentists(dentist_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_appt_date (appointment_date),
  INDEX idx_appt_status (status)
) ENGINE=InnoDB;

-- Payments
CREATE TABLE IF NOT EXISTS payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATE NOT NULL,
  method ENUM('Cash','Card','EVC') DEFAULT 'Cash',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_payment_date (payment_date)
) ENGINE=InnoDB;


-- Treatments
CREATE TABLE IF NOT EXISTS treatments (
  treatment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  dentist_id INT NOT NULL,
  treatment_name VARCHAR(100) NOT NULL,
  treatment_date DATE NOT NULL,
  cost DECIMAL(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_treatments_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_treatments_dentist FOREIGN KEY (dentist_id) REFERENCES dentists(dentist_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_treatment_date (treatment_date)
) ENGINE=InnoDB;

-- Optional sample data (commented)
-- INSERT INTO dentists(first_name,last_name,specialization,phone,email) VALUES
-- ('Alice','Smith','Orthodontics','+10000000001','alice@example.com'),
-- ('Bob','Brown','Endodontics','+10000000002','bob@example.com');
