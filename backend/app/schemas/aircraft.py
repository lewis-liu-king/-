from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime, date


class AircraftBase(BaseModel):
    aircraft_number: str
    model: str
    status: str = "active"
    commission_date: Optional[date] = None


class AircraftCreate(AircraftBase):
    pass


class AircraftUpdate(BaseModel):
    aircraft_number: Optional[str] = None
    model: Optional[str] = None
    status: Optional[str] = None
    commission_date: Optional[date] = None


class AircraftResponse(AircraftBase):
    aircraft_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class AircraftListResponse(BaseModel):
    items: list[AircraftResponse]
    total: int
    page: int
    page_size: int
