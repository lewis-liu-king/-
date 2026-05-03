from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class OperatorBase(BaseModel):
    name: str
    employee_id: str
    role: str
    contact_info: Optional[str] = None


class OperatorCreate(OperatorBase):
    pass


class OperatorUpdate(BaseModel):
    name: Optional[str] = None
    employee_id: Optional[str] = None
    role: Optional[str] = None
    contact_info: Optional[str] = None


class OperatorResponse(OperatorBase):
    operator_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class OperatorListResponse(BaseModel):
    items: list[OperatorResponse]
    total: int
    page: int
    page_size: int
