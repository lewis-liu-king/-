from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class MaintenanceBase(BaseModel):
    component_id: int
    work_order_number: str
    maintenance_type: str
    description: Optional[str] = None
    operator_id: Optional[int] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    result: Optional[str] = None
    notes: Optional[str] = None


class MaintenanceCreate(MaintenanceBase):
    pass


class MaintenanceUpdate(BaseModel):
    maintenance_type: Optional[str] = None
    description: Optional[str] = None
    operator_id: Optional[int] = None
    end_time: Optional[datetime] = None
    result: Optional[str] = None
    notes: Optional[str] = None


class MaintenanceResponse(BaseModel):
    maintenance_id: int
    component_id: int
    work_order_number: str
    maintenance_type: str
    description: Optional[str]
    operator_id: Optional[int]
    start_time: datetime
    end_time: Optional[datetime]
    result: Optional[str]
    notes: Optional[str]
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class MaintenanceListResponse(BaseModel):
    items: list[MaintenanceResponse]
    total: int
    page: int
    page_size: int
