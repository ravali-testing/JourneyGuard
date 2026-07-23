# ========================================================
# JourneyGuard UK - Booking Validation Engine
# Module: Week 4 - Python Engineering & Backend Logic
# ========================================================

import re

def validate_email(email: str) -> bool:
    """Validates UK user email format."""
    email_regex = r"^[\w\.-]+@[\w\.-]+\.\w+$"
    return bool(re.match(email_regex, email)) if email else False

def validate_station_codes(origin_code: str, destination_code: str) -> bool:
    """Validates origin and destination station codes."""
    if not origin_code or not destination_code:
        raise ValueError("Station codes cannot be empty.")
    
    origin = origin_code.strip().upper()
    dest = destination_code.strip().upper()

    if len(origin) != 3 or len(dest) != 3:
        raise ValueError("Station codes must be 3-letter CRS codes (e.g., KGX, MAN).")

    if origin == dest:
        raise ValueError("Origin and destination stations cannot be the same.")

    return True

def validate_passenger_count(passengers: list, ticket_quantity: int) -> bool:
    """Ensures passenger list matches booking ticket quantity."""
    if not passengers:
        raise ValueError("Passenger list cannot be empty.")
    
    if len(passengers) != ticket_quantity:
        raise ValueError(f"Passenger count ({len(passengers)}) does not match ticket quantity ({ticket_quantity}).")

    return True