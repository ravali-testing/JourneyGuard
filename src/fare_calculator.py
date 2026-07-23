# ========================================================
# JourneyGuard UK - Fare & Discount Calculation Engine
# Module: Week 4 - Python Engineering & Backend Logic
# ========================================================

VALID_RAILCARDS = {
    "SIXTEEN_TWENTYFIVE": 0.34,  # 34% discount
    "SENIOR": 0.34,               # 34% discount
    "TWO_TOGETHER": 0.34,         # 34% discount
    "FAMILY_FRIENDS": 0.60        # 60% discount for children (simplified logic)
}

def calculate_fare(base_price: float, railcard_type: str = None, ticket_quantity: int = 1) -> dict:
    """
    Calculates final fare, applied discount, and total for a booking.
    """
    if base_price <= 0:
        raise ValueError("Base price must be greater than zero.")
    
    if ticket_quantity < 1:
        raise ValueError("Ticket quantity must be at least 1.")

    discount_rate = 0.0
    if railcard_type:
        normalized_railcard = railcard_type.upper().strip()
        if normalized_railcard in VALID_RAILCARDS:
            discount_rate = VALID_RAILCARDS[normalized_railcard]
        else:
            raise ValueError(f"Invalid railcard type: {railcard_type}")

    unit_discount = round(base_price * discount_rate, 2)
    final_unit_price = round(base_price - unit_discount, 2)
    total_price = round(final_unit_price * ticket_quantity, 2)

    return {
        "base_price": base_price,
        "discount_rate": discount_rate,
        "unit_discount": unit_discount,
        "final_unit_price": final_unit_price,
        "ticket_quantity": ticket_quantity,
        "total_price": total_price
    }