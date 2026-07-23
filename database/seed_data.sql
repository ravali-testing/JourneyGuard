-- Insert Seed Data into Roles
INSERT INTO roles (role_id, role_name) VALUES 
(1, 'CUSTOMER'), (2, 'ADMIN');

-- Insert Seed Users
INSERT INTO users (user_id, email, password_hash, role_id, status) VALUES 
(1, 'john.doe@example.com', 'hashed_pass_123', 1, 'ACTIVE'),
(2, 'sarah.smith@example.com', 'hashed_pass_456', 1, 'ACTIVE'),
(3, 'admin.user@journeyguard.co.uk', 'hashed_pass_789', 2, 'ACTIVE'),
(4, 'expired.user@example.com', 'hashed_pass_000', 1, 'INACTIVE');

-- Insert Customer Profiles
INSERT INTO customer_profiles (profile_id, user_id, first_name, last_name, phone_number, date_of_birth) VALUES 
(1, 1, 'John', 'Doe', '07123456789', '1998-05-12'),
(2, 2, 'Sarah', 'Smith', '07987654321', '2001-11-23'),
(3, 4, 'Expired', 'Account', '07000000000', '1985-01-01');

-- Insert Railcards (Including valid and expired ones)
INSERT INTO railcards (railcard_id, user_id, railcard_number, type, discount_rate, expiry_date, status) VALUES 
(1, 1, 'RC-1625-998811', '16-25 Railcard', 0.33, '2027-12-31', 'ACTIVE'),
(2, 4, 'RC-EXPIRED-001', '16-25 Railcard', 0.33, '2023-01-01', 'EXPIRED');

-- Insert Stations
INSERT INTO stations (station_id, station_code, station_name) VALUES 
(1, 'KGX', 'London King''s Cross'),
(2, 'MAN', 'Manchester Piccadilly'),
(3, 'BHM', 'Birmingham New Street');

-- Insert Journeys
INSERT INTO journeys (journey_id, departure_station_id, arrival_station_id, departure_time, arrival_time, standard_price) VALUES 
(1, 1, 2, '2026-08-10 08:00:00', '2026-08-10 10:15:00', 85.00),
(2, 2, 1, '2026-08-12 17:30:00', '2026-08-12 19:45:00', 85.00),
(3, 1, 3, '2026-08-15 09:00:00', '2026-08-15 10:30:00', 45.00);

-- Insert Bookings (Includes valid bookings and synthetic anomaly cases)
INSERT INTO bookings (booking_id, booking_reference, user_id, journey_id, railcard_id, ticket_quantity, original_price, discount_amount, final_price, status) VALUES 
(1, 'JG-BK-1001', 1, 1, 1, 1, 85.00, 28.05, 56.95, 'CONFIRMED'),
(2, 'JG-BK-1002', 2, 2, NULL, 2, 170.00, 0.00, 170.00, 'CONFIRMED'),
(3, 'JG-BK-1003', 1, 3, 2, 1, 45.00, 22.50, 22.50, 'CONFIRMED'); -- Anomaly: Used expired railcard with incorrect 50% discount!

-- Insert Payments
INSERT INTO payments (payment_id, booking_id, payment_reference, amount, payment_status) VALUES 
(1, 1, 'PAY-882211', 56.95, 'SUCCESS'),
(2, 2, 'PAY-882212', 170.00, 'SUCCESS'),
(3, 3, 'PAY-882213', 22.50, 'SUCCESS');