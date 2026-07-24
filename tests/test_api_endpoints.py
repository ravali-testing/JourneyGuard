# ========================================================
# JourneyGuard UK - Automated REST API Tests
# Module: Week 5 - API Testing & Integration
# ========================================================

import pytest
from src.api_server import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_get_stations_all(client):
    """Test retrieving all train stations."""
    response = client.get("/v1/stations")
    assert response.status_code == 200
    data = response.get_json()
    assert "stations" in data
    assert len(data["stations"]) == 5


def test_get_stations_query_filter(client):
    """Test searching station by CRS code query."""
    response = client.get("/v1/stations?query=KGX")
    assert response.status_code == 200
    data = response.get_json()
    assert len(data["stations"]) == 1
    assert data["stations"][0]["crs_code"] == "KGX"


def test_calculate_fare_api_success(client):
    """Test POST /v1/fares/calculate with railcard discount."""
    payload = {
        "base_price": 100.00,
        "railcard_type": "SIXTEEN_TWENTYFIVE",
        "ticket_quantity": 1,
    }
    response = client.post("/v1/fares/calculate", json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert data["total_price"] == 66.00


def test_calculate_fare_api_invalid(client):
    """Test POST /v1/fares/calculate with negative base price."""
    payload = {"base_price": -10.00, "ticket_quantity": 1}
    response = client.post("/v1/fares/calculate", json=payload)
    assert response.status_code == 400
    data = response.get_json()
    assert "error" in data


def test_create_booking_success(client):
    """Test POST /v1/bookings creates a confirmed booking."""
    payload = {
        "origin": "KGX",
        "destination": "MAN",
        "passenger_email": "test.user@journeyguard.co.uk",
        "passengers": ["Test User"],
        "base_price": 100.00,
        "railcard_type": "SENIOR",
    }
    response = client.post("/v1/bookings", json=payload)
    assert response.status_code == 201
    data = response.get_json()
    assert data["status"] == "CONFIRMED"
    assert data["total_price"] == 66.00
    assert "booking_id" in data


def test_get_booking_details_success(client):
    """Test GET /v1/bookings/<booking_id> for existing booking."""
    response = client.get("/v1/bookings/JG-84920")
    assert response.status_code == 200
    data = response.get_json()
    assert data["booking_id"] == "JG-84920"
    assert data["origin"] == "KGX"


def test_get_booking_details_not_found(client):
    """Test GET /v1/bookings/<booking_id> for non-existent reference."""
    response = client.get("/v1/bookings/JG-99999")
    assert response.status_code == 404
    data = response.get_json()
    assert data["error"] == "Booking reference not found"