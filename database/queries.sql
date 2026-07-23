-- ========================================================
-- JourneyGuard UK Core & Advanced Query Suite
-- Module: Week 3 - SQL, Database Design & Backend Validation
-- ========================================================

-- ================================================
-- SECTION 1: CORE CRUD, FILTERING & JOIN QUERIES (1-15)
-- ================================================

-- 1. Retrieve all active users and their roles
SELECT u.user_id, u.email, u.status, r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.status = 'ACTIVE';

-- 2. Find customer profile details for active users
SELECT u.user_id, cp.first_name, cp.last_name, u.email, cp.phone_number
FROM users u
JOIN customer_profiles cp ON u.user_id = cp.user_id;

-- 3. Retrieve all valid (non-expired) railcards
SELECT r.railcard_number, r.type, r.discount_rate, r.expiry_date, cp.first_name, cp.last_name
FROM railcards r
JOIN users u ON r.user_id = u.user_id
JOIN customer_profiles cp ON u.user_id = cp.user_id
WHERE r.expiry_date >= CURRENT_DATE AND r.status = 'ACTIVE';

-- 4. Find all bookings made by a specific user with full journey details
SELECT b.booking_reference, cp.first_name, cp.last_name, s1.station_name AS origin, s2.station_name AS destination, b.final_price, b.status
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN customer_profiles cp ON u.user_id = cp.user_id
JOIN journeys j ON b.journey_id = j.journey_id
JOIN stations s1 ON j.departure_station_id = s1.station_id
JOIN stations s2 ON j.arrival_station_id = s2.station_id;

-- 5. Retrieve payment status for all confirmed bookings
SELECT b.booking_reference, p.payment_reference, p.amount, p.payment_status, p.processed_at
FROM bookings b
LEFT JOIN payments p ON b.booking_id = p.booking_id;

-- 6. Identify orphan bookings (bookings without payment records)
SELECT b.booking_id, b.booking_reference, b.final_price
FROM bookings b
LEFT JOIN payments p ON b.booking_id = p.booking_id
WHERE p.payment_id IS NULL;

-- 7. Get total revenue generated per departure station
SELECT s.station_name AS departure_station, SUM(b.final_price) AS total_revenue
FROM bookings b
JOIN journeys j ON b.journey_id = j.journey_id
JOIN stations s ON j.departure_station_id = s.station_id
WHERE b.status = 'CONFIRMED'
GROUP BY s.station_name;

-- 8. Find users who have applied for railcards but have no active railcard
SELECT u.user_id, u.email, ra.railcard_type, ra.status AS application_status
FROM railcard_applications ra
JOIN users u ON ra.user_id = u.user_id
LEFT JOIN railcards r ON u.user_id = r.user_id
WHERE r.railcard_id IS NULL;

-- 9. Search journeys between London King's Cross (KGX) and Manchester Piccadilly (MAN)
SELECT j.journey_id, s1.station_code AS origin, s2.station_code AS destination, j.departure_time, j.standard_price
FROM journeys j
JOIN stations s1 ON j.departure_station_id = s1.station_id
JOIN stations s2 ON j.arrival_station_id = s2.station_id
WHERE s1.station_code = 'KGX' AND s2.station_code = 'MAN';

-- 10. List bookings with discounts applied
SELECT booking_reference, original_price, discount_amount, final_price
FROM bookings
WHERE discount_amount > 0;

-- 11. Count passengers booked per booking reference
SELECT b.booking_reference, COUNT(bp.passenger_id) AS total_passengers
FROM bookings b
JOIN booking_passengers bp ON b.booking_id = bp.booking_id
GROUP BY b.booking_reference;

-- 12. Find all open support cases with customer contact details
SELECT sc.case_id, sc.subject, sc.status, u.email, cp.phone_number
FROM support_cases sc
JOIN users u ON sc.user_id = u.user_id
JOIN customer_profiles cp ON u.user_id = cp.user_id
WHERE sc.status = 'OPEN';

-- 13. Update support case status to IN_PROGRESS
UPDATE support_cases 
SET status = 'IN_PROGRESS' 
WHERE case_id = 1;

-- 14. Find bookings created within the last 30 days
SELECT booking_reference, created_at, final_price
FROM bookings
WHERE created_at >= NOW() - INTERVAL 30 DAY;

-- 15. Delete inactive user records with no historical bookings
DELETE FROM users 
WHERE status = 'INACTIVE' 
AND user_id NOT IN (SELECT DISTINCT user_id FROM bookings);


-- ================================================
-- SECTION 2: AGGREGATES, SUBQUERIES & HAVING (16-25)
-- ================================================

-- 16. Calculate average ticket discount amount per railcard type
SELECT r.type, AVG(b.discount_amount) AS avg_discount
FROM bookings b
JOIN railcards r ON b.railcard_id = r.railcard_id
GROUP BY r.type;

-- 17. Find customers who have spent more than £100 in total
SELECT u.user_id, cp.first_name, cp.last_name, SUM(b.final_price) AS total_spent
FROM users u
JOIN customer_profiles cp ON u.user_id = cp.user_id
JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, cp.first_name, cp.last_name
HAVING SUM(b.final_price) > 100.00;

-- 18. Find journeys priced higher than the average journey price
SELECT journey_id, standard_price
FROM journeys
WHERE standard_price > (SELECT AVG(standard_price) FROM journeys);

-- 19. Identify the most popular journey route by booking count
SELECT j.journey_id, s1.station_name AS origin, s2.station_name AS destination, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN journeys j ON b.journey_id = j.journey_id
JOIN stations s1 ON j.departure_station_id = s1.station_id
JOIN stations s2 ON j.arrival_station_id = s2.station_id
GROUP BY j.journey_id, s1.station_name, s2.station_name
ORDER BY total_bookings DESC
LIMIT 1;

-- 20. Count total users grouped by user role
SELECT r.role_name, COUNT(u.user_id) AS user_count
FROM users u
JOIN roles r ON u.role_id = r.role_id
GROUP BY r.role_name;

-- 21. Retrieve customer details who made more than 1 booking
SELECT u.email, COUNT(b.booking_id) AS booking_count
FROM users u
JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.email
HAVING COUNT(b.booking_id) > 1;

-- 22. Find railcards that are expiring within 60 days
SELECT railcard_number, type, expiry_date
FROM railcards
WHERE expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL 60 DAY;

-- 23. Find bookings where the payment amount does NOT match the final price (Reconciliation Query)
SELECT b.booking_reference, b.final_price, p.amount AS payment_amount
FROM bookings b
JOIN payments p ON b.booking_id = p.booking_id
WHERE b.final_price <> p.amount;

-- 24. Calculate total refund potential from cancelled bookings
SELECT SUM(final_price) AS total_cancelled_amount
FROM bookings
WHERE status = 'CANCELLED';

-- 25. Find users who have never placed a booking
SELECT u.user_id, u.email
FROM users u
WHERE u.user_id NOT IN (SELECT DISTINCT user_id FROM bookings WHERE user_id IS NOT NULL);


-- ================================================
-- SECTION 3: ADVANCED CTES & WINDOW FUNCTIONS (26-40+)
-- ================================================

-- 26. CTE: Calculate booking summary per user
WITH UserBookingSummary AS (
    SELECT user_id, COUNT(booking_id) AS total_bookings, SUM(final_price) AS total_spent
    FROM bookings
    GROUP BY user_id
)
SELECT u.email, ubs.total_bookings, ubs.total_spent
FROM UserBookingSummary ubs
JOIN users u ON ubs.user_id = u.user_id;

-- 27. Window Function: Rank customers by total spend
SELECT u.user_id, cp.first_name, cp.last_name, SUM(b.final_price) AS total_spent,
       RANK() OVER (ORDER BY SUM(b.final_price) DESC) AS spend_rank
FROM users u
JOIN customer_profiles cp ON u.user_id = cp.user_id
JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, cp.first_name, cp.last_name;

-- 28. Window Function: Number user bookings sequentially (ROW_NUMBER)
SELECT booking_id, user_id, booking_reference, created_at,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at ASC) AS user_booking_seq
FROM bookings;

-- 29. Window Function: Calculate running total of daily booking revenue
SELECT CAST(created_at AS DATE) AS booking_date,
       SUM(final_price) AS daily_revenue,
       SUM(SUM(final_price)) OVER (ORDER BY CAST(created_at AS DATE)) AS running_total_revenue
FROM bookings
WHERE status = 'CONFIRMED'
GROUP BY CAST(created_at AS DATE);

-- 30. Window Function: Compare booking price against previous booking using LAG
SELECT booking_id, user_id, final_price,
       LAG(final_price, 1) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_booking_price
FROM bookings;

-- 31. Window Function: Peek at next booking date using LEAD
SELECT booking_id, user_id, created_at,
       LEAD(created_at, 1) OVER (PARTITION BY user_id ORDER BY created_at) AS next_booking_date
FROM bookings;

-- 32. CTE: Identify suspicious bookings made using expired railcards (Anomaly Detection)
WITH ExpiredRailcardBookings AS (
    SELECT b.booking_id, b.booking_reference, b.created_at, r.expiry_date
    FROM bookings b
    JOIN railcards r ON b.railcard_id = r.railcard_id
    WHERE r.expiry_date < CAST(b.created_at AS DATE)
)
SELECT * FROM ExpiredRailcardBookings;

-- 33. CTE: Railcard discount validation (Check if discount math is correct)
WITH DiscountValidation AS (
    SELECT booking_reference, original_price, discount_amount, final_price,
           (original_price - discount_amount) AS expected_final_price
    FROM bookings
)
SELECT * FROM DiscountValidation
WHERE final_price <> expected_final_price;

-- 34. Detect potential duplicate user accounts by matching names
SELECT first_name, last_name, COUNT(profile_id) AS occurrence_count
FROM customer_profiles
GROUP BY first_name, last_name
HAVING COUNT(profile_id) > 1;

-- 35. CTE: Monthly Booking Frequency Analysis
WITH MonthlyMetrics AS (
    SELECT DATE_FORMAT(created_at, '%Y-%m') AS booking_month,
           COUNT(booking_id) AS total_bookings,
           SUM(final_price) AS monthly_revenue
    FROM bookings
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
)
SELECT * FROM MonthlyMetrics ORDER BY booking_month DESC;

-- 36. Categorise booking size using CASE statement
SELECT booking_reference, ticket_quantity,
       CASE 
           WHEN ticket_quantity = 1 THEN 'Solo Travel'
           WHEN ticket_quantity BETWEEN 2 AND 4 THEN 'Group/Family'
           ELSE 'Large Group'
       END AS travel_category
FROM bookings;

-- 37. Find station journeys with zero current bookings
SELECT j.journey_id, s1.station_name AS origin, s2.station_name AS destination
FROM journeys j
LEFT JOIN bookings b ON j.journey_id = b.journey_id
JOIN stations s1 ON j.departure_station_id = s1.station_id
JOIN stations s2 ON j.arrival_station_id = s2.station_id
WHERE b.booking_id IS NULL;

-- 38. Reconcile passenger seat counts against ticket quantities
SELECT b.booking_reference, b.ticket_quantity, COUNT(bp.passenger_id) AS passenger_records
FROM bookings b
LEFT JOIN booking_passengers bp ON b.booking_id = bp.booking_id
GROUP BY b.booking_reference, b.ticket_quantity
HAVING b.ticket_quantity <> COUNT(bp.passenger_id);

-- 39. Identify users with failed payment transactions
SELECT u.email, b.booking_reference, p.payment_status
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN users u ON b.user_id = u.user_id
WHERE p.payment_status = 'FAILED';

-- 40. Retrieve latest audit trail for customer security events
SELECT ae.event_id, u.email, ae.action_type, ae.description, ae.event_time
FROM audit_events ae
LEFT JOIN users u ON ae.user_id = u.user_id
ORDER BY ae.event_time DESC;