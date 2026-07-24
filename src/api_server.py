# ========================================================
# JourneyGuard UK - Mock REST API Server
# Module: Week 5 - API Testing & Integration
# ========================================================

from flask import Flask, request, jsonify
from src.fare_calculator import calculate_fare
from src.booking_validator import validate_station_codes, validate_email, validate_passenger_count

app = Flask(__name__)

STATIONS_DB = [
    {"crs_code": "KGX", "name": "London King's Cross", "zone": 1},
    {"crs_code": "MAN", "name": "Manchester Piccadilly", "zone": 2},
    {"crs_code": "BHM", "name": "Birmingham New Street", "zone": 2},
    {"crs_code": "LVP", "name": "Liverpool Lime Street", "zone": 3},
    {"crs_code": "EDB", "name": "Edinburgh Waverley", "zone": 4},
]

BOOKINGS_DB = {
    "JG-84920": {
        "booking_id": "JG-84920",
        "status": "CONFIRMED",
        "origin": "KGX",
        "destination": "MAN",
        "passenger_email": "sarah.smith@journeyguard.co.uk",
        "total_price": 66.00,
    }
}


@app.route("/v1/stations", methods=["GET"])
def get_stations():
    query = request.args.get("query", "").upper()
    if query:
        filtered = [s for s in STATIONS_DB if query in s["crs_code"] or query in s["name"].upper()]
        return jsonify({"stations": filtered}), 200
    return jsonify({"stations": STATIONS_DB}), 200


@app.route("/v1/fares/calculate", methods=["POST"])
def api_calculate_fare():
    data = request.get_json() or {}
    try:
        base_price = data.get("base_price")
        railcard_type = data.get("railcard_type")
        ticket_quantity = data.get("ticket_quantity", 1)

        result = calculate_fare(
            base_price=base_price,
            railcard_type=railcard_type,
            ticket_quantity=ticket_quantity,
        )
        return jsonify(result), 200
    except ValueError as e:
        return jsonify({"error": str(e), "status_code": 400}), 400


@app.route("/v1/bookings", methods=["POST"])
def create_booking():
    data = request.get_json() or {}
    try:
        origin = data.get("origin")
        destination = data.get("destination")
        email = data.get("passenger_email")
        passengers = data.get("passengers", [])
        base_price = data.get("base_price")
        railcard = data.get("railcard_type")

        validate_station_codes(origin, destination)
        validate_email(email)
        validate_passenger_count(passengers, len(passengers))

        fare = calculate_fare(base_price=base_price, railcard_type=railcard, ticket_quantity=len(passengers))

        booking_id = f"JG-{len(BOOKINGS_DB) + 84921}"
        booking = {
            "booking_id": booking_id,
            "status": "CONFIRMED",
            "origin": origin,
            "destination": destination,
            "passenger_email": email,
            "total_price": fare["total_price"],
        }
        BOOKINGS_DB[booking_id] = booking
        return jsonify(booking), 201
    except ValueError as e:
        return jsonify({"error": str(e), "status_code": 400}), 400


@app.route("/v1/bookings/<booking_id>", methods=["GET"])
def get_booking(booking_id):
    booking = BOOKINGS_DB.get(booking_id)
    if not booking:
        return jsonify({"error": "Booking reference not found", "status_code": 404}), 404
    return jsonify(booking), 200


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000, debug=True)