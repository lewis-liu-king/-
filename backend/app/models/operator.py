from sqlalchemy import Column, Integer, String, Text, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base
import enum


class OperatorRole(str, enum.Enum):
    technician = "technician"
    inspector = "inspector"
    manager = "manager"


class Operator(Base):
    __tablename__ = "operators"
    
    operator_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    employee_id = Column(String(50), nullable=False, unique=True)
    role = Column(String(50), nullable=False)
    contact_info = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    installations_as_installer = relationship(
        "InstallationRecord",
        foreign_keys="InstallationRecord.installation_operator_id",
        back_populates="installation_operator"
    )
    installations_as_remover = relationship(
        "InstallationRecord",
        foreign_keys="InstallationRecord.removal_operator_id",
        back_populates="removal_operator"
    )
    maintenances = relationship("MaintenanceRecord", back_populates="operator")
    retirements = relationship("ScrapOrRetirementRecord", back_populates="approval_operator")
