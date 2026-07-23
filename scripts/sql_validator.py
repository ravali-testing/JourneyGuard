# ========================================================
# JourneyGuard UK - SQL & Backend Data Quality Utility
# Module: Week 3 - SQL Database & Backend Quality Framework
# ========================================================

import csv
import datetime
import os

def run_data_quality_checks():
    """
    Simulates automated database data quality & reconciliation checks.
    Exports exceptions to a CSV report.
    """
    print("==================================================")
    print("   JourneyGuard Backend SQL Quality Validator     ")
    print("==================================================")
    
    # Define simulated reconciliation checks
    quality_checks = [
        {
            "check_id": "DQ-001",
            "name": "Reconcile Payment vs Booking Final Price",
            "query": "SELECT * FROM bookings b JOIN payments p ON b.booking_id=p.booking_id WHERE b.final_price <> p.amount",
            "status": "PASSED",
            "exceptions_found": 0
        },
        {
            "check_id": "DQ-002",
            "name": "Detect Expired Railcard Usage in Active Bookings",
            "query": "SELECT * FROM bookings b JOIN railcards r ON b.railcard_id=r.railcard_id WHERE r.expiry_date < b.created_at",
            "status": "FAILED",
            "exceptions_found": 1  # Detects anomaly created in seed_data.sql!
        },
        {
            "check_id": "DQ-003",
            "name": "Check Passenger Count vs Ticket Quantity Mismatch",
            "query": "SELECT b.booking_reference FROM bookings b LEFT JOIN booking_passengers bp ON b.booking_id=bp.booking_id GROUP BY b.booking_reference HAVING b.ticket_quantity <> COUNT(bp.passenger_id)",
            "status": "PASSED",
            "exceptions_found": 0
        },
        {
            "check_id": "DQ-004",
            "name": "Detect Duplicate Customer Account Names",
            "query": "SELECT first_name, last_name FROM customer_profiles GROUP BY first_name, last_name HAVING COUNT(*) > 1",
            "status": "PASSED",
            "exceptions_found": 0
        },
        {
            "check_id": "DQ-005",
            "name": "Identify Orphan Bookings Without Payment Records",
            "query": "SELECT * FROM bookings b LEFT JOIN payments p ON b.booking_id=p.booking_id WHERE p.payment_id IS NULL",
            "status": "PASSED",
            "exceptions_found": 0
        }
    ]

    # Create output report directory if it doesn't exist
    reports_dir = os.path.join(os.path.dirname(__file__), '..', 'reports')
    os.makedirs(reports_dir, exist_ok=True)
    report_file = os.path.join(reports_dir, 'sql_data_quality_report.csv')

    # Export results to CSV
    with open(report_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Check_ID", "Check_Name", "SQL_Query", "Status", "Exceptions_Count", "Timestamp"])
        
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        for check in quality_checks:
            writer.writerow([
                check["check_id"],
                check["name"],
                check["query"],
                check["status"],
                check["exceptions_found"],
                timestamp
            ])
            print(f"[{check['status']}] {check['check_id']}: {check['name']} - Exceptions: {check['exceptions_found']}")

    print("\n--------------------------------------------------")
    print(f"Report generated successfully: {os.path.abspath(report_file)}")
    print("==================================================")

if __name__ == "__main__":
    run_data_quality_checks()