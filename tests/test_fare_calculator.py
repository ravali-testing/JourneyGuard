# ========================================================
# JourneyGuard UK - Unit Tests for Fare Calculator
# Module: Week 4 - Python Engineering, Pytest & Unit Testing
# ========================================================

import pytest
from src.fare_calculator import calculate_fare


def test_standard_fare_no_railcard():
    """Test standard fare calculation without any railcard."""
    result = calculate_fare(base_price=100.00, railcard_type=None, ticket_quantity=1)
    assert result["base_price"] == 100.00
    assert result["discount_rate"] == 0.0
    assert result["unit_discount"] == 0.0
    assert result["total_price"] == 100.00


def test_sixteen_twentyfive_railcard_discount():
    """Test 16-25 railcard discount (34% off)."""
    result = calculate_fare(base_price=50.00, railcard_type="SIXTEEN_TWENTYFIVE", ticket_quantity=1)
    assert result["discount_rate"] == 0.34
    assert result["unit_discount"] == 17.00
    assert result["total_price"] == 33.00


def test_multiple_tickets_fare_calculation():
    """Test calculation for multiple tickets with senior railcard."""
    result = calculate_fare(base_price=80.00, railcard_type="SENIOR", ticket_quantity=2)
    assert result["final_unit_price"] == 52.80
    assert result["total_price"] == 105.60


def test_invalid_base_price_raises_error():
    """Test that zero or negative base price raises ValueError."""
    with pytest.raises(ValueError, match="Base price must be greater than zero"):
        calculate_fare(base_price=0.00)


def test_invalid_railcard_raises_error():
    """Test that unsupported railcard raises ValueError."""
    with pytest.raises(ValueError, match="Invalid railcard type"):
        calculate_fare(base_price=50.00, railcard_type="SUPER_SAVER")