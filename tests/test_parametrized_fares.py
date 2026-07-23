# ========================================================
# JourneyGuard UK - Parametrized Unit Tests
# Module: Week 4 - Python Engineering, Pytest & Unit Testing
# ========================================================

import pytest
from src.fare_calculator import calculate_fare
from src.booking_validator import validate_station_codes


@pytest.mark.parametrize(
    "base_price, railcard_type, quantity, expected_total",
    [
        (100.00, None, 1, 100.00),
        (100.00, "SIXTEEN_TWENTYFIVE", 1, 66.00),
        (100.00, "SENIOR", 1, 66.00),
        (100.00, "TWO_TOGETHER", 1, 66.00),
        (100.00, "FAMILY_FRIENDS", 1, 40.00),
        (50.00, "SIXTEEN_TWENTYFIVE", 2, 66.00),
        (10.00, None, 5, 50.00),
    ],
)
def test_parametrized_fare_calculations(
    base_price, railcard_type, quantity, expected_total
):
    """Parametrized test for multiple fare and discount combinations."""
    result = calculate_fare(
        base_price=base_price,
        railcard_type=railcard_type,
        ticket_quantity=quantity,
    )
    assert result["total_price"] == expected_total


@pytest.mark.parametrize(
    "origin, destination",
    [
        ("KGX", "MAN"),
        ("bhm", "kgx"),
        ("LVP", "EDB"),
        ("PAD", "BRI"),
    ],
)
def test_valid_station_combinations(origin, destination):
    """Parametrized test for multiple valid station pairs."""
    assert validate_station_codes(origin, destination) is True


@pytest.mark.parametrize(
    "origin, destination, expected_error_msg",
    [
        ("KGX", "KGX", "Origin and destination stations cannot be the same"),
        ("LON", "LON", "Origin and destination stations cannot be the same"),
        ("INVALID", "MAN", "must be 3-letter CRS codes"),
        ("K", "MAN", "must be 3-letter CRS codes"),
    ],
)
def test_invalid_station_combinations(origin, destination, expected_error_msg):
    """Parametrized test for invalid station pairs triggering expected errors."""
    with pytest.raises(ValueError, match=expected_error_msg):
        validate_station_codes(origin, destination)