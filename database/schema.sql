-- ========================================================
-- JourneyGuard UK Database Schema
-- Module: Week 3 - Backend Quality & SQL Framework
-- ========================================================

-- Drop tables if they exist to allow clean re-runs
DROP TABLE IF EXISTS audit_events;
DROP TABLE IF EXISTS support_cases;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS booking_passengers;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS journeys;
DROP TABLE IF EXISTS stations;
DROP TABLE IF EXISTS railcard_applications;
DROP TABLE IF EXISTS railcards;
DROP TABLE IF EXISTS customer_profiles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- 1. Roles Table
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- 3. Customer Profiles Table
CREATE TABLE customer_profiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 4. Railcards Table
CREATE TABLE railcards (
    railcard_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    railcard_number VARCHAR(30) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL, -- e.g., 16-25, Senior, Family & Friends
    discount_rate DECIMAL(5,2) NOT NULL CHECK (discount_rate >= 0.00 AND discount_rate <= 1.00),
    expiry_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 5. Railcard Applications Table
CREATE TABLE railcard_applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    railcard_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by_user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (approved_by_user_id) REFERENCES users(user_id)
);

-- 6. Stations Table
CREATE TABLE stations (
    station_id INT PRIMARY KEY AUTO_INCREMENT,
    station_code VARCHAR(10) UNIQUE NOT NULL, -- e.g., KGX, MAN, BHM
    station_name VARCHAR(100) NOT NULL
);

-- 7. Journeys Table
CREATE TABLE journeys (
    journey_id INT PRIMARY KEY AUTO_INCREMENT,
    departure_station_id INT NOT NULL,
    arrival_station_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    standard_price DECIMAL(10,2) NOT NULL CHECK (standard_price > 0),
    FOREIGN KEY (departure_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (arrival_station_id) REFERENCES stations(station_id),
    CONSTRAINT chk_station_diff CHECK (departure_station_id <> arrival_station_id)
);

-- 8. Bookings Table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_reference VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    journey_id INT NOT NULL,
    railcard_id INT NULL,
    ticket_quantity INT NOT NULL CHECK (ticket_quantity > 0),
    original_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    final_price DECIMAL(10,2) NOT NULL CHECK (final_price >= 0),
    status VARCHAR(20) DEFAULT 'CONFIRMED', -- CONFIRMED, CANCELLED, PENDING
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (journey_id) REFERENCES journeys(journey_id),
    FOREIGN KEY (railcard_id) REFERENCES railcards(railcard_id)
);

-- 9. Booking Passengers Table
CREATE TABLE booking_passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    passenger_name VARCHAR(100) NOT NULL,
    ticket_type VARCHAR(30) DEFAULT 'ADULT',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- 10. Payments Table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_reference VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL, -- SUCCESS, FAILED, TIMED_OUT
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- 11. Support Cases Table
CREATE TABLE support_cases (
    case_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    booking_id INT NULL,
    subject VARCHAR(150) NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- 12. Audit Events Table
CREATE TABLE audit_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action_type VARCHAR(50) NOT NULL,
    description TEXT,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);