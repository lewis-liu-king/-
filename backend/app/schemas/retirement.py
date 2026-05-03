from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class RetirementBase(BaseModel):
    component_id: int
    retirement_reason: str
    approval_operator_id: Optional[int] = None
    retirement_time: datetime
    notes: Optional[str] = None


class RetirementCreate(BaseModel):
    component_id: int
    retirement_reason: str
    approval_operator_id: Optional[int] = None
    notes: Optional[str] = None
    retirement_time: Optional[datetime] = None


class RetirementResponse(BaseModel):
    retirement_id: int
    component_id: int
    retirement_reason: str
    approval_operator_id: Optional[int]
    retirement_time: datetime
    notes: Optional[str]
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class RetirementListResponse(BaseModel):
    items: list[RetirementResponse]
    total: int
    page: int
    page_size: int
