from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from decimal import Decimal


class FlightBase(BaseModel):
    aircraft_id: int
    flight_number: Optional[str] = None
    mission_type: str
    departure_airport: Optional[str] = None
    arrival_airport: Optional[str] = None
    takeoff_time: datetime
    landing_time: Optional[datetime] = None
    flight_duration_hours: Optional[Decimal] = None
    notes: Optional[str] = None


class FlightCreate(FlightBase):
    pass


class FlightUpdate(BaseModel):
    flight_number: Optional[str] = None
    mission_type: Optional[str] = None
    departure_airport: Optional[str] = None
    arrival_airport: Optional[str] = None
    takeoff_time: Optional[datetime] = None
    landing_time: Optional[datetime] = None
    flight_duration_hours: Optional[Decimal] = None
    notes: Optional[str] = None


class FlightResponse(FlightBase):
    flight_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class FlightListResponse(BaseModel):
    items: list[FlightResponse]
    total: int
    page: int
    page_size: int
