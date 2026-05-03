from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime, date
from decimal import Decimal


class ComponentBase(BaseModel):
    component_serial: str
    model_id: int
    batch_number: Optional[str] = None
    manufacture_date: Optional[date] = None
    status: str = "available"
    total_usage_hours: Optional[Decimal] = Decimal("0")
    is_retired: bool = False


class ComponentCreate(ComponentBase):
    pass


class ComponentUpdate(BaseModel):
    component_serial: Optional[str] = None
    model_id: Optional[int] = None
    batch_number: Optional[str] = None
    manufacture_date: Optional[date] = None
    status: Optional[str] = None
    total_usage_hours: Optional[Decimal] = None


class ComponentResponse(ComponentBase):
    component_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class ComponentDetailResponse(ComponentResponse):
    model_code: Optional[str] = None
    model_category: Optional[str] = None


class ComponentListResponse(BaseModel):
    items: list[ComponentResponse]
    total: int
    page: int
    page_size: int
