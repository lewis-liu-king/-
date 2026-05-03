from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class InstallationBase(BaseModel):
    component_id: int
    aircraft_id: int
    installation_position: str
    installation_reason: Optional[str] = None
    installation_operator_id: Optional[int] = None
    installation_time: datetime
    removal_reason: Optional[str] = None
    removal_operator_id: Optional[int] = None
    removal_time: Optional[datetime] = None


class InstallationCreate(BaseModel):
    component_id: int
    aircraft_id: int
    installation_position: str
    installation_reason: Optional[str] = None
    installation_operator_id: Optional[int] = None
    installation_time: Optional[datetime] = None


class InstallationRemove(BaseModel):
    removal_reason: str
    removal_operator_id: Optional[int] = None
    removal_time: Optional[datetime] = None


class InstallationResponse(BaseModel):
    installation_id: int
    component_id: int
    aircraft_id: int
    installation_position: str
    installation_reason: Optional[str]
    installation_operator_id: Optional[int]
    installation_time: datetime
    removal_reason: Optional[str]
    removal_operator_id: Optional[int]
    removal_time: Optional[datetime]
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class InstallationListResponse(BaseModel):
    items: list[InstallationResponse]
    total: int
    page: int
    page_size: int
