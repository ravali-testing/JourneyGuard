# ========================================================
# JourneyGuard UK - Unit Tests for Booking Validator
# Module: Week 4 - Python Engineering, Pytest & Unit Testing
# ========================================================

import pytest
from src.booking_validator import validate_email, validate_station_codes, validate_passenger_count


def test_valid_email_formats():
    """Test valid email addresses."""
    assert validate_email("john.doe@example.com") is True
    assert validate_email("sarah.smith@journeyguard.co.uk") is True


def test_invalid_email_formats():
    """Test invalid email addresses."""
    assert validate_email("invalid-email") is False
    assert validate_email("john.doe@") is False
    assert validate_email("") is False


def test_valid_station_codes():
    """Test valid CRS station codes."""
    assert validate_station_codes("KGX", "MAN") is True
    assert validate_station_codes("kgx", "bhm") is True  # Case insensitive check


def test_same_origin_and_destination_raises_error():
    """Test that identical origin and destination raises ValueError."""
    with pytest.raises(ValueError, match="Origin and destination stations cannot be the same"):
        validate_station_codes("KGX", "KGX")


def test_invalid_station_code_length_raises_error():
    """Test that non-3-letter codes raise ValueError."""
    with pytest.raises(ValueError, match="must be 3-letter CRS codes"):
        validate_station_codes("LONDON", "MAN")


def test_passenger_count_matching():
    """Test valid passenger list length matching ticket quantity."""
    passengers = ["John Doe", "Sarah Smith"]
    assert validate_passenger_count(passengers, ticket_quantity=2) is True


def test_passenger_count_mismatch_raises_error():
    """Test that passenger count mismatch raises ValueError."""
    passengers = ["John Doe"]
    with pytest.raises(ValueError, match="Passenger count .* does not match ticket quantity"):
        validate_passenger_count(passengers, ticket_quantity=2)