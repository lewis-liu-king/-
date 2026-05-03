from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class ComponentModelBase(BaseModel):
    model_code: str
    category: str
    design_life_hours: Optional[int] = None
    maintenance_interval_hours: Optional[int] = None
    applicable_aircraft_models: Optional[str] = None
    description: Optional[str] = None


class ComponentModelCreate(ComponentModelBase):
    pass


class ComponentModelUpdate(BaseModel):
    model_code: Optional[str] = None
    category: Optional[str] = None
    design_life_hours: Optional[int] = None
    maintenance_interval_hours: Optional[int] = None
    applicable_aircraft_models: Optional[str] = None
    description: Optional[str] = None


class ComponentModelResponse(ComponentModelBase):
    model_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class ComponentModelListResponse(BaseModel):
    items: list[ComponentModelResponse]
    total: int
    page: int
    page_size: int
