from sqlalchemy import Column, Integer, String, Date, DateTime, DECIMAL, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Component(Base):
    __tablename__ = "components"
    
    component_id = Column(Integer, primary_key=True, autoincrement=True)
    component_serial = Column(String(50), nullable=False, unique=True)
    model_id = Column(Integer, ForeignKey("component_models.model_id"), nullable=False)
    batch_number = Column(String(50))
    manufacture_date = Column(Date)
    status = Column(String(30), nullable=False, default="available")
    total_usage_hours = Column(DECIMAL(10, 2), default=0)
    is_retired = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    model = relationship("ComponentModel", back_populates="components")
    installations = relationship("InstallationRecord", back_populates="component")
    maintenances = relationship("MaintenanceRecord", back_populates="component")
    retirement = relationship("ScrapOrRetirementRecord", back_populates="component", uselist=False)
